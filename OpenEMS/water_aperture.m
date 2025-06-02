%
% script

addpath('/usr/share/octave/packages/openems-0.0.35');
addpath('/usr/share/octave/packages/csxcad-0.0.35');


close all
clear
clc

%% setup the simulation
physical_constants;
unit = 1e-3; % all length in mm


%% setup FDTD parameter & excitation function
f0 = 915e6; % center frequency
fc = 150e6; % 20 dB corner frequency

%setup feeding
feed.R = 50;     %feed resistance

%open AppCSXCAD and show

disp( '1) Show model' );
disp( '2) Run simulation' );
disp( '3) Show model & Run simulation' );

show = 0;
runsim = 0;

EXP = input("Enter a choice:");
if (EXP == 1)
  show = 1;
  runsim = 0;
elseif (EXP == 2)
  show = 0;
  runsim = 1;
elseif (EXP == 3)
  show = 1;
  runsim = 1;
else
  disp( 'Script terminated' );
  return;
end

%  _______________________________________________         +
% |                                               |\      /|\
% |                                               | |      |
% |                                               | |      |
% |                                               | |      |
% |    _________________________________59.7__    | |      |
% |   |               5|                      |   | |      |
% |   |   _____________|___________________   |   | |      |
% |   |   |                               | 5 |   | |      |
% |   |   |________________________54.7___|   |   | |      Y
% |   |                                       |   | |      |
% |   |_________3|______ _______________59.7__|   | |      |
% |                                               | |      |
% |                                               | |      |
% |                                               | |      |
% |                                               | |      |
% |_______________________________________________| |     \|/
%  \_______________________________________________\|      -
%
%               <------- X -------->



%% setup CSXCAD geometry & mesh
CSX = InitCSX();

%% ============== Substrate ======================

substrate1.epsR   = 4.3;
substrate1.kappa  = 1e-3 * 2*pi*f0 * EPS0*substrate1.epsR;

CSX = AddMaterial( CSX, 'substrate1');
CSX = SetMaterialProperty( CSX, 'substrate1', 'Epsilon',substrate1.epsR, 'Kappa', substrate1.kappa);

substrate1.width  = 120;             % X of substrate1
substrate1.length = 120;           % Y of substrate1
substrate1.yoffset = substrate1.length/2;           % Y offset
substrate1.thickness = 1.5;         % thickness of substrate1
substrate1.cells = 4;               % use 4 cells for meshing substrate1

start = [-substrate1.width/2  substrate1.yoffset  0];
stop  = start + [ substrate1.width   -substrate1.length  -substrate1.thickness];
CSX = AddBox( CSX, 'substrate1', 1, start, stop );

%% ============== Water ======================

water.epsR   = 80;
water.kappa  = 0.05 * 2*pi*f0 * EPS0*water.epsR;

CSX = AddMaterial( CSX, 'water');
CSX = SetMaterialProperty( CSX, 'water', 'Epsilon', water.epsR, 'Kappa', water.kappa);

water.width  = substrate1.width;             % X of substrate1
water.length = substrate1.length;           % Y of substrate1
water.yoffset = water.length/2;           % Y offset
water.thickness = 120;         % thickness of substrate1
water.cells = 120;               % use 4 cells for meshing substrate1

start = [-water.width/2  water.yoffset  0];
stop  = start + [ water.width   -water.length  water.thickness];
CSX = AddBox( CSX, 'water', 1, start, stop );

%% ============== Slot ======================

slot_x = 25;
slot_y = 1;

CSX = AddMetal( CSX, 'slot' ); % create a perfect electric conductor (PEC)

start = [-slot_x/2 -substrate1.length/2 0];
stop = [-substrate1.width/2 substrate1.length/2 0];
CSX = AddBox( CSX, 'slot', 10,  start, stop);  % Narrow line 1

start = [slot_x/2 -substrate1.length/2 0];
stop = [substrate1.width/2 substrate1.length/2 0];
CSX = AddBox( CSX, 'slot', 10,  start, stop);  % Narrow line 1


start = [-slot_x/2 -slot_y/2 0];
stop = [slot_x/2 -substrate1.length/2 0];        % -1 is port gap
CSX = AddBox( CSX, 'slot', 10,  start, stop);  % Narrow line 1

start = [-slot_x/2 slot_y/2 0];
stop = [slot_x/2 substrate1.length/2 0];        % -1 is port gap
CSX = AddBox( CSX, 'slot', 10,  start, stop);  % Narrow line 1


%% ============== Port ======================
start = [-0.5 -slot_y/2 0];
stop = start + [1 slot_y 0];   % port 1mm wide, 
[CSX port] = AddLumpedPort(CSX, 5 ,1 ,feed.R, start, stop, [0 1 0], true);  % port field: Y direction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size of the simulation box
SimBox = [substrate1.width substrate1.length water.thickness*2];


FDTD = InitFDTD('NrTS',  60000, 'EndCriteria', 1e-4 ); % -30 dB
FDTD = SetGaussExcite( FDTD, f0, fc );
BC = {'MUR' 'MUR' 'MUR' 'MUR' 'MUR' 'MUR'}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );


%initialize the mesh with the "air-box" dimensions
mesh.x = [-SimBox(1)/2 SimBox(1)/2];
mesh.y = [-SimBox(2)/2 SimBox(2)/2];
mesh.z = [-SimBox(3)/2 SimBox(3)/2];


% add extra cells to discretize the substrate1 thickness
mesh.z = [linspace(0,-substrate1.thickness,substrate1.cells+1) mesh.z];
mesh.z = [linspace(0,water.thickness,water.cells+1) mesh.z];



slot_mesh = DetectEdges(CSX, [], 'SetProperty','slot');
mesh.x = [mesh.x SmoothMeshLines(slot_mesh.x, 1.5)];
mesh.y = [mesh.y SmoothMeshLines(slot_mesh.y, 1.5)];


%% finalize the mesh
% generate a smooth mesh with max. cell size: lambda_min / 40
mesh = DetectEdges(CSX, mesh);
mesh = SmoothMesh(mesh, c0 / (f0+fc) / unit / 40);
CSX = DefineRectGrid(CSX, unit, mesh);

%% add a nf2ff calc box; size is 3 cells away from MUR boundary condition
start = [mesh.x(4)     mesh.y(4)     mesh.z(4)];
stop  = [mesh.x(end-3) mesh.y(end-3) mesh.z(end-3)];
[CSX nf2ff] = CreateNF2FFBox(CSX, 'nf2ff', start, stop);

%% prepare simulation folder
Sim_Path = 'tmp_WATERSLOT';
Sim_CSX = 'WATERSLOT.xml';

try confirm_recursive_rmdir(false,'local'); end

[status, message, messageid] = rmdir( Sim_Path, 's' ); % clear previous directory
[status, message, messageid] = mkdir( Sim_Path ); % create empty simulation folder

%% write openEMS compatible xml-file
WriteOpenEMS( [Sim_Path '/' Sim_CSX], FDTD, CSX );

%% show the structure
if (show == 1)
  CSXGeomPlot( [Sim_Path '/' Sim_CSX] );
end

if (runsim != 1)
  disp( 'Script terminated' );
  return;
end

%% run openEMS
RunOpenEMS( Sim_Path, Sim_CSX);  %RunOpenEMS( Sim_Path, Sim_CSX, '--debug-PEC -v');

%% postprocessing & do the plots
freq = linspace( f0-fc, f0+fc, 201 );
port = calcPort(port, Sim_Path, freq);



Zin = port.uf.tot ./ port.if.tot;
s11 = port.uf.ref ./ port.uf.inc;
P_in = real(0.5 * port.uf.tot .* conj( port.if.tot )); % antenna feed power


%% Smith chart port reflection
%%%plotRefl(port, 'threshold', -10)
%%%title( 'reflection coefficient' );


% plot feed point impedance
figure
plot( freq/1e6, real(Zin), 'k-', 'Linewidth', 2 );
hold on
grid on
plot( freq/1e6, imag(Zin), 'r--', 'Linewidth', 2 );
title( 'feed point impedance' );
xlabel( 'frequency f / MHz' );
ylabel( 'impedance Z_{in} / Ohm' );
legend( 'real', 'imag' );

% plot reflection coefficient S11
figure
plot( freq/1e6, 20*log10(abs(s11)), 'k-', 'Linewidth', 2 );
grid on
title( 'reflection coefficient S_{11}' );
xlabel( 'frequency f / MHz' );
ylabel( 'reflection coefficient |S_{11}|' );

drawnow

%% NFFF contour plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find resonance frequency from s11
f_res_ind = find(s11==min(s11));
f_res = freq(f_res_ind)
%%%f_res = 950e6; %%%%%%%%%%%%%%%%


disp( ['S11 min frequency = ' f_res/1e6 ' MHz']);

%%
disp( 'calculating 3D far field pattern and dumping to vtk (use Paraview to visualize)...' );
thetaRange = (0:2:180);
phiRange = (0:2:360) - 180;
nf2ff = CalcNF2FF(nf2ff, Sim_Path, f_res, thetaRange*pi/180, phiRange*pi/180,'Verbose',1,'Outfile','3D_Pattern.h5');
figure
plotFF3D(nf2ff)

% display power and directivity
disp( ['radiated power: Prad = ' num2str(nf2ff.Prad) ' Watt']);
disp( ['directivity: Dmax = ' num2str(nf2ff.Dmax) ' (' num2str(10*log10(nf2ff.Dmax)) ' dBi)'] );
disp( ['efficiency: nu_rad = ' num2str(100*nf2ff.Prad./real(P_in(f_res_ind))) ' %']);

E_far_normalized = nf2ff.E_norm{1} / max(nf2ff.E_norm{1}(:)) * nf2ff.Dmax;
DumpFF2VTK([Sim_Path '/3D_Pattern.vtk'],E_far_normalized,thetaRange,phiRange,1e-3);



% s11  list of complex numbers, as per freq

pause();
