%
% script

addpath('/usr/share/octave/packages/openems-0.0.35');
addpath('/usr/share/octave/packages/csxcad-0.0.35');

addpath("../../RFlib");

close all
clear
clc

% setup the simulation
physical_constants;
unit = 1e-3; % all length in mm


% setup FDTD parameter & excitation function
f0 = 5.0e9; % center frequency
max_recursion_depth(2048)
fc = 3e9;

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


% Kicad footprint "Capacitor_SMD:C_0603_1608Metric"
%  * X = 0.95 mm
%  * Y = 0.9 mm
% OSHPark 4-layer 
%  * h = 0.2 mm
%  * Dk = 3.61
%  * W @ 50 ohm = 0.382 mm
%  * min. width = 0.127 mm (5 mil)

%  _______________________________________________         +
% |                                               |\      /|\
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |       
% |                      | |                      | |      Y
% |                      | |                      | |       
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |_______________________________________________| |     \|/
%  \_______________________________________________\|      -
%
%              - <------- X --------> +



% setup CSXCAD geometry & mesh
CSX = InitCSX();



% ============== Materials ======================

CSX = AddMetal( CSX, 'copper' ); % create a perfect electric conductor (PEC)
% Isola FR408HR @ 5GHz
losstangent = 0.0098; 
substrate.epsR   = 3.61;
substrate.kappa  = losstangent * 2*pi*f0 * EPS0*substrate.epsR;

CSX = AddMaterial(CSX, 'substrate');
CSX = SetMaterialProperty(CSX, 'substrate', 'Epsilon', substrate.epsR, 'Kappa', substrate.kappa);

% ============== Substrate ======================

substrate.x = 7.5;             % X of substrate
substrate.y = 50;           % Y of substrate
substrate.cells = 8;               % use 4 cells for meshing substrate
substrate.thickness = 0.2;         % thickness of substrate

% Substrate 
start = [-substrate.x/2 -substrate.y/2 0];
stop = start + [substrate.x substrate.y -substrate.thickness];
CSX = AddBox( CSX, 'substrate', 10,  start, stop);



smdpad_x = 0.95;
smdpad_y = 0.90;

copper_thickness = 0.035;
feedline_width = 0.381;         % X
feedline_end = smdpad_y / 2;


% ============== Pad ======================

start = [-smdpad_x/2 -smdpad_y/2 0];
stop = start + [smdpad_x smdpad_y copper_thickness];
CSX = AddBox( CSX, 'copper', 20,  start, stop);

% ============== Feedline 1 ======================

start = [-feedline_width/2 -substrate.y/2 0];
stop = [feedline_width/2 -feedline_end copper_thickness];
CSX = AddBox( CSX, 'copper', 20,  start, stop);

start = [-feedline_width/2 -substrate.y/2 0];
stop = start + [feedline_width 0 -substrate.thickness];
[CSX port{1}] = AddLumpedPort(CSX, 50, 1, feed.R, start, stop, [0 0 1], true);  % port field: Z direction


% ============== Feedline 2 ======================

start = [-feedline_width/2 substrate.y/2 0];
stop = [feedline_width/2 feedline_end copper_thickness];
CSX = AddBox( CSX, 'copper', 20,  start, stop);

start = [-feedline_width/2 substrate.y/2 0];
stop = start + [feedline_width 0 -substrate.thickness];
[CSX port{2}] = AddLumpedPort(CSX, 50, 2, feed.R, start, stop, [0 0 1], false);  % port field: Z direction


% =============================================================================
% size of the simulation box
SimBox = [substrate.x  substrate.y*1.1];


FDTD = InitFDTD('NrTS',  80000, 'EndCriteria', 1e-4 ); % -30 dB
FDTD = SetGaussExcite( FDTD, f0, fc );
BC = {'MUR' 'MUR' 'MUR' 'MUR' 'PEC' 'MUR'}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );


%initialize the mesh with the "air-box" dimensions
mesh.x = [-SimBox(1)/2 SimBox(1)/2];
mesh.y = [-SimBox(2)/2 SimBox(2)/2];
mesh.z = [-substrate.thickness substrate.thickness*20];


% add extra cells to discretize the substrate1 thickness
mesh.z = [linspace(0 ,-substrate.thickness, substrate.cells+1) mesh.z];



%  This makes things very slow
more_mesh = DetectEdges(CSX, [], 'SetProperty','copper');  % copper previously
  mesh.x = [mesh.x SmoothMeshLines(more_mesh.x, 1.5)];
  mesh.y = [mesh.y SmoothMeshLines(more_mesh.y, 1.5)];


%% finalize the mesh
% generate a smooth mesh with max. cell size: lambda_min / 40
mesh = DetectEdges(CSX, mesh);
mesh = SmoothMesh(mesh, c0 / (f0+fc) / unit / 480);
CSX = DefineRectGrid(CSX, unit, mesh);

%% E-field dump

efield_x_dump_start = [-(SimBox(1)/2) 0 -substrate.thickness];
efield_x_dump_stop = efield_x_dump_start + [SimBox(1) 0 substrate.thickness*20];

%CSX = AddDump(CSX,'Ef','DumpType', 10, 'Frequency', f0);   %% Frequency domain efield
CSX = AddDump(CSX,'Efield_x','DumpType', 0, 'DumpMode', 2);     %% Time domain efield
CSX = AddBox(CSX, 'Efield_x', 1, efield_x_dump_start, efield_x_dump_stop);

efield_y_dump_start = [0 -(SimBox(2)/2) -substrate.thickness];
efield_y_dump_stop = efield_y_dump_start + [0 SimBox(2) substrate.thickness*20];

%CSX = AddDump(CSX,'Ef','DumpType', 10, 'Frequency', f0);   %% Frequency domain efield
CSX = AddDump(CSX,'Efield_y','DumpType', 0, 'DumpMode', 2);     %% Time domain efield
CSX = AddBox(CSX, 'Efield_y', 1, efield_y_dump_start, efield_y_dump_stop);


% prepare simulation folder
Sim_Path = 'tmp_MICROSTRIP_0603PAD';
Sim_CSX = 'MICROSTRIP_0603PAD.xml';

try confirm_recursive_rmdir(false,'local'); end

[status, message, messageid] = rmdir( Sim_Path, 's' ); % clear previous directory
[status, message, messageid] = mkdir( Sim_Path ); % create empty simulation folder

% write openEMS compatible xml-file
WriteOpenEMS( [Sim_Path '/' Sim_CSX], FDTD, CSX );

% show the structure
if (show == 1)
  CSXGeomPlot( [Sim_Path '/' Sim_CSX] );
end

if (runsim != 1)
  disp( 'Script terminated' );
  return;
end

% run openEMS
RunOpenEMS( Sim_Path, Sim_CSX);  %RunOpenEMS( Sim_Path, Sim_CSX, '--debug-PEC -v');

% postprocessing & do the plots
freq = linspace( f0-fc, f0+fc, 201 );
port = calcPort(port, Sim_Path, freq);

ts = sweep2ts(freq);

Zin = port{1}.uf.tot ./ port{1}.if.tot;
s11 = port{1}.uf.ref ./ port{1}.uf.inc;
s21 = port{2}.uf.ref ./ port{1}.uf.inc;

for fp = 1:length(freq)
    ts.points(fp).f = freq(fp);
    ts.points(fp).S(1,1) = s11(fp);
    ts.points(fp).S(2,1) = s21(fp);
end

plot2ports_fwd(ts, 100);

pause();
