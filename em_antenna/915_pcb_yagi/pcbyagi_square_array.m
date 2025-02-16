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
feed.R = 200;     %feed resistance

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

%  _______________________________________________
% |    _________________________________59.7__    |\
% |   |               5|                      |   | |      +
% |   |   _____________|___________________   |   | |     /|\
% |   |   |                               | 5 |   | |      |
% |   |   |________________________54.7___|   |   | |      |
% |   |_________3|______ _______________59.7__|   | |      |
% |                                               | |
% |                    port:2                     | |
% |  ___________________________________________  | |      Y
% | |                                           | | |
% | |____________________________________70_____| | |      |
% |_______________________________________________| |     \|/
%  \_______________________________________________\|      -
%
%               <------- X -------->


dp_length = 59.7;
dpn_width = 3;
dpw_width = 5;
dp_sep = 8.5;

ref_length = 70;
ref_width = 12;
ref_sep = 44.5;

%% setup CSXCAD geometry & mesh
CSX = InitCSX();


% === PEC ===
CSX = AddMetal( CSX, 'dipole' ); % create a perfect electric conductor (PEC)

% === Substrate ===
substrate1.epsR   = 4.3;
substrate1.kappa  = 1e-3 * 2*pi*f0 * EPS0*substrate1.epsR;
CSX = AddMaterial( CSX, 'substrate1');
CSX = SetMaterialProperty( CSX, 'substrate1', 'Epsilon',substrate1.epsR, 'Kappa', substrate1.kappa);


N_elements = 4;

separation = 165;

z_placement = -((N_elements - 1) * separation / 2);

ports = [];


for ant_idx = 1:N_elements

    % ============== Dipole ======================

    start = [-dp_length 0 z_placement];
    stop = start + [dp_length-1 dpn_width 0];        % -1 is port gap
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Narrow line 1

    start = [dp_length 0 z_placement];
    stop = start + [-(dp_length-1) dpn_width 0];     % -1 is port gap
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Narrow line 2

    start = [-dp_length dpn_width+dp_sep z_placement];
    stop =  start + [dp_length*2 dpw_width 0];
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Thick line

    start = [-dp_length dpn_width z_placement];
    stop =  start + [dpw_width dp_sep 0];
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Side 1

    start = [dp_length dpn_width z_placement];
    stop =  start + [-(dpw_width) dp_sep 0];
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Side 1


    start = [-ref_length -ref_sep z_placement];
    stop =  start + [ref_length*2 -ref_width 0];
    CSX = AddBox( CSX, 'dipole', 10, start, stop);  % Reflector

    % ============== Substrate ======================

    substrate1.width  = 154;             % width of substrate1
    substrate1.yoffset = 22.5;           % Y offset
    substrate1.length = 86.5;           % length of substrate1
    substrate1.thickness = 1.5;         % thickness of substrate1
    substrate1.cells = 4;               % use 4 cells for meshing substrate1

    start = [-substrate1.width/2  substrate1.yoffset  z_placement];
    stop  = start + [ substrate1.width   -substrate1.length  substrate1.thickness];
    CSX = AddBox( CSX, 'substrate1', 1, start, stop );


    % ============== Port ======================
    start = [-1 0 z_placement];
    stop = start + [2 dpn_width 0];


    [CSX port] = AddLumpedPort(CSX, 5, ant_idx, feed.R, start, stop, [1 0 0], true);
    ports = [ports; port];

    z_placement = z_placement + separation;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size of the simulation box
SimBox = [substrate1.width*3 substrate1.length*3 (ant_idx+1)*separation];


FDTD = InitFDTD('NrTS',  60000 );
FDTD = SetGaussExcite( FDTD, f0, fc );
BC = {'MUR' 'MUR' 'MUR' 'MUR' 'MUR' 'MUR'}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );


%initialize the mesh with the "air-box" dimensions
mesh.x = [-SimBox(1)/2 SimBox(1)/2];
mesh.y = [-SimBox(2)/2 SimBox(2)/2];
mesh.z = [-SimBox(3)/2 SimBox(3)/2];


% add extra cells to discretize the substrate1 thickness
mesh.z = [linspace(0,substrate1.thickness,substrate1.cells+1) mesh.z];



dipole_mesh = DetectEdges(CSX, [], 'SetProperty','dipole');
mesh.x = [mesh.x SmoothMeshLines(dipole_mesh.x, 1.5)];
mesh.y = [mesh.y SmoothMeshLines(dipole_mesh.y, 1.5)];


%% finalize the mesh
% generate a smooth mesh with max. cell size: lambda_min / 40
mesh = DetectEdges(CSX, mesh);
mesh = SmoothMesh(mesh, c0 / (f0 + fc) / unit / 40);
CSX = DefineRectGrid(CSX, unit, mesh);

%% add a nf2ff calc box; size is 3 cells away from MUR boundary condition
start = [mesh.x(4)     mesh.y(4)     mesh.z(4)];
stop  = [mesh.x(end-3) mesh.y(end-3) mesh.z(end-3)];
[CSX nf2ff] = CreateNF2FFBox(CSX, 'nf2ff', start, stop);

%% prepare simulation folder
Sim_Path = 'tmp_PCBYAGI_array';
Sim_CSX = 'PCBYAGI_array.xml';

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
port_results = [];
for ant_idx = 1:N_elements
    port_results = [port_results; calcPort(ports(ant_idx), Sim_Path, freq)];
end

Zin = port_results(1).uf.tot ./ port_results(1).if.tot;
s11 = port_results(1).uf.ref ./ port_results(1).uf.inc;
P_in = real(0.5 * port_results(1).uf.tot .* conj( port_results(1).if.tot )); % antenna feed power


%% Smith chart port_results(1) reflection
plotRefl(port_results(1), 'threshold', -10)
title( 'reflection coefficient' );


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

%%
disp( 'calculating 3D far field pattern and dumping to vtk (use Paraview to visualize)...' );
thetaRange = (0:2:180);
phiRange = (0:2:360) - 180;
nf2ff = CalcNF2FF(nf2ff, Sim_Path, f0, thetaRange*pi/180, phiRange*pi/180,'Verbose',1,'Outfile','3D_Pattern.h5');
figure
plotFF3D(nf2ff);

% display power and directivity
disp( ['radiated power: Prad = ' num2str(nf2ff.Prad) ' Watt']);
disp( ['directivity: Dmax = ' num2str(nf2ff.Dmax) ' (' num2str(10*log10(nf2ff.Dmax)) ' dBi)'] );
%disp( ['efficiency: nu_rad = ' num2str(100*nf2ff.Prad./real(P_in(f_res_ind))) ' %']);

E_far_normalized = nf2ff.E_norm{1} / max(nf2ff.E_norm{1}(:)) * nf2ff.Dmax;
DumpFF2VTK([Sim_Path '/3D_Pattern.vtk'],E_far_normalized,thetaRange,phiRange,1e-3);


% s11  list of complex numbers, as per freq

pause();
