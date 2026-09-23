%
% script

%addpath('/usr/share/octave/packages/openems-0.0.35');
%addpath('/usr/share/octave/packages/csxcad-0.0.35');

addpath('/home/mk/tmp/RF_Microwave/OpenEMS/openems/share/openEMS/matlab')
addpath('/home/mk/tmp/RF_Microwave/OpenEMS/openems/share/CSXCAD/matlab')


addpath("../RFlib");

close all
clear
clc

% setup the simulation
physical_constants;
unit = 1e-3; % all length in mm


% setup FDTD parameter & excitation function
f0 = 5800e6; % center frequency
max_recursion_depth(2048)
fc = 1000e6; % 20 dB corner frequency, 150MHz originally

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
% |               __________________              | |      |
% |               |                |              | |      |
% |               |                |              | |      |
% |               |   ----------   |              | |      |
% |               |   ----------   |              | |      Y
% |               |                |              | |      |
% |               |                |              | |      |
% |               ------------------              | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |                      | |                      | |      |
% |_______________________________________________| |     \|/
%  \_______________________________________________\|      -
%
%               <------- X -------->



% setup CSXCAD geometry & mesh
CSX = InitCSX();


_z_offset_ = -50;

x_separation = 12.93; % lambda / 4 at 5.8 GHz in free space

% ============== Substrate ======================

% Isola FR408HR @ 5GHz
losstangent = 0.0098; 
substrate.epsR   = 3.61;
substrate.kappa  = losstangent * 2*pi*f0 * EPS0*substrate.epsR;

CSX = AddMaterial( CSX, 'substrate');
CSX = SetMaterialProperty( CSX, 'substrate', 'Epsilon',substrate.epsR, 'Kappa', substrate.kappa);

substrate.x = 100;             % X of substrate
substrate.y = 100;           % Y of substrate
substrate.cells = 4;               % use 4 cells for meshing substrate
substrate.thickness_1 = 1.2;         % thickness of substrate towards the patch
substrate.thickness_2 = 0.2;         % thickness of substrate towards the feedline

stack_thickness = 1.5;
gap = 4;

% +Z : stack
start = [-(substrate.x/2)  -substrate.y/2  _z_offset_ + substrate.thickness_1 + gap];
stop  = start + [ substrate.x   substrate.y  stack_thickness];
CSX = AddBox( CSX, 'substrate', 10, start, stop );

% +Z : patch
start = [-(substrate.x/2)  -substrate.y/2  _z_offset_];
stop  = start + [ substrate.x   substrate.y  substrate.thickness_1];
CSX = AddBox( CSX, 'substrate', 10, start, stop );

% -Z : feedline
start = [-(substrate.x/2)  -substrate.y/2  _z_offset_];
stop  = start + [ substrate.x   substrate.y  -substrate.thickness_2];
CSX = AddBox( CSX, 'substrate', 10, start, stop );


% ============== Slot ======================

slot_length = 8;              % X
slot_width = 0.55;  % Y

CSX = AddMetal( CSX, 'copper' ); % create a perfect electric conductor (PEC)

% Big copper plane
start = [-substrate.x/2 -substrate.y/2 _z_offset_];
stop = start + [substrate.x substrate.y 0];
CSX = AddBox( CSX, 'copper', 20,  start, stop);

for element = [1 2 3 4]

    if (element == 1)
        x_separation = 17;
        y_separation = 17;  % 17, 12.93
    end
    if (element == 2) 
        x_separation = 17;
        y_separation = -17;
    end
    if (element == 3) 
        x_separation = -17;
        y_separation = 17;
    end
    if (element == 4) 
        x_separation = -17;
        y_separation = -17;
    end

    % Slot
    start = [-(slot_length/2 + x_separation) (-slot_width/2 + y_separation) _z_offset_];
    stop = start + [slot_length slot_width 0];
    CSX = AddBox( CSX, 'substrate', 30, start, stop );

    % ============== Patch ======================

    % Upper

    patch_length =  12 * 1.125;              % X
    patch_width = 11.4; %11.2              % Y the resonant length

    start = [-(patch_length/2 + x_separation) (-patch_width/2 + y_separation) (substrate.thickness_1 + _z_offset_ + stack_thickness + gap)];
    stop = start + [patch_length patch_width 0];
    CSX = AddBox( CSX, 'copper', 20,  start, stop);

    % Lower

    patch_length =  12 * 1.125;              % X
    patch_width = 11.4; % 11.2              % Y the resonant length

    start = [-(patch_length/2 + x_separation) (-patch_width/2 + y_separation) (substrate.thickness_1 + _z_offset_)];
    stop = start + [patch_length patch_width 0];
    CSX = AddBox( CSX, 'copper', 20,  start, stop);


    % ============== Feedline ======================

    feedline_width = 0.381;         % X
    feedline_stub_length = 7.8;       % Y

    start = [-(feedline_width/2 + x_separation) (-feedline_stub_length + y_separation) -substrate.thickness_2+_z_offset_];
    stop = start + [feedline_width feedline_stub_length*2 0];
    CSX = AddBox( CSX, 'copper', 20,  start, stop);


    % ============== Port ======================
    start = [-(feedline_width/2 + x_separation) (-feedline_stub_length + y_separation) -substrate.thickness_2+_z_offset_];
    stop = start + [feedline_width 0 substrate.thickness_2];
    if (element == 1)
        [CSX port{1}] = AddLumpedPort(CSX, 50 ,1 ,feed.R, start, stop, [0 0 1], true);  % port field: Z direction
    end
    if (element == 2) 
        [CSX port{2}] = AddLumpedPort(CSX, 50 ,2 ,feed.R, start, stop, [0 0 1], true);  % port field: Z direction
    end
    if (element == 3) 
        [CSX port{3}] = AddLumpedPort(CSX, 50 ,3 ,feed.R, start, stop, [0 0 1], true);  % port field: Z direction
    end
    if (element == 4) 
        [CSX port{4}] = AddLumpedPort(CSX, 50 ,4 ,feed.R, start, stop, [0 0 1], true);  % port field: Z direction
    end
end


% =============================================================================
% size of the simulation box
SimBox = [substrate.x*2  substrate.y*2 substrate.x*3];


FDTD = InitFDTD('NrTS',  80000, 'EndCriteria', 1e-4 ); % -30 dB
FDTD = SetGaussExcite( FDTD, f0, fc );
BC = {'MUR' 'MUR' 'MUR' 'MUR' 'MUR' 'MUR'}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );


%initialize the mesh with the "air-box" dimensions
mesh.x = [-SimBox(1)/2 SimBox(1)/2];
mesh.y = [-SimBox(2)/2 SimBox(2)/2];
mesh.z = [-SimBox(3)/2 SimBox(3)/2];


% add extra cells to discretize the substrate1 thickness
mesh.z = [linspace(_z_offset_ ,substrate.thickness_1, substrate.cells+1) mesh.z];
mesh.z = [linspace(_z_offset_ ,-substrate.thickness_2, substrate.cells+1) mesh.z];



%  This makes things very slow
slot_mesh = DetectEdges(CSX, [], 'SetProperty','copper');  % copper previously
  mesh.x = [mesh.x SmoothMeshLines(slot_mesh.x, 1.5)];
  mesh.y = [mesh.y SmoothMeshLines(slot_mesh.y, 1.5)];


%% finalize the mesh
% generate a smooth mesh with max. cell size: lambda_min / 40
mesh = DetectEdges(CSX, mesh);
mesh = SmoothMesh(mesh, c0 / (f0+fc) / unit / 90);
CSX = DefineRectGrid(CSX, unit, mesh);

%% add a nf2ff calc box; size is 3 cells away from MUR boundary condition
start = [mesh.x(4)     mesh.y(4)     mesh.z(4)];
stop  = [mesh.x(end-3) mesh.y(end-3) mesh.z(end-3)];
[CSX nf2ff] = CreateNF2FFBox(CSX, 'nf2ff', start, stop);

%% E-field dump

efield_x_dump_start = [-(SimBox(1)/2) 0 -(SimBox(3)/2)];
efield_x_dump_stop = efield_x_dump_start + [SimBox(1) 0 SimBox(3)];

%CSX = AddDump(CSX,'Ef','DumpType', 10, 'Frequency', f0);   %% Frequency domain efield
CSX = AddDump(CSX,'Efield_x','DumpType', 0, 'DumpMode', 2);     %% Time domain efield
CSX = AddBox(CSX, 'Efield_x', 1, efield_x_dump_start, efield_x_dump_stop);

efield_y_dump_start = [0 -(SimBox(2)/2) -(SimBox(3)/2)];
efield_y_dump_stop = efield_y_dump_start + [0 SimBox(2) SimBox(3)];

%CSX = AddDump(CSX,'Ef','DumpType', 10, 'Frequency', f0);   %% Frequency domain efield
CSX = AddDump(CSX,'Efield_y','DumpType', 0, 'DumpMode', 2);     %% Time domain efield
CSX = AddBox(CSX, 'Efield_y', 1, efield_y_dump_start, efield_y_dump_stop);




% prepare simulation folder
Sim_Path = 'tmp_APERTURE_COUPLED_PATCH_ARRAY';
Sim_CSX = 'APERTURE_COUPLED_PATCH_ARRAY.xml';

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

s11 = port{1}.uf.ref ./ port{1}.uf.inc;
s21 = port{2}.uf.ref ./ port{1}.uf.inc;
f_res_ind = find(s11==min(s11));

for fp = 1:length(freq)
    ts.points(fp).f = freq(fp);
    ts.points(fp).S(1,1) = s11(fp);
    ts.points(fp).S(2,1) = s21(fp);
end

plot2ports_fwd(ts, f_res_ind);

drawnow

%find resonance frequency from s11
f_res = freq(f_res_ind)

disp( 'calculating 3D far field pattern and dumping to vtk (use Paraview to visualize)...' );
thetaRange = (0:2:180);
phiRange = (0:2:360) - 180;
nf2ff = CalcNF2FF(nf2ff, Sim_Path, f_res, thetaRange*pi/180, phiRange*pi/180,'Verbose',1,'Outfile','3D_Pattern.h5');
figure
plotFF3D(nf2ff)

% display power and directivity
disp( ['radiated power: Prad = ' num2str(nf2ff.Prad) ' Watt']);
disp( ['directivity: Dmax = ' num2str(nf2ff.Dmax) ' (' num2str(10*log10(nf2ff.Dmax)) ' dBi)'] );
%disp( ['efficiency: nu_rad = ' num2str(100*nf2ff.Prad./real(P_in(f_res_ind))) ' %']);

E_far_normalized = nf2ff.E_norm{1} / max(nf2ff.E_norm{1}(:)) * nf2ff.Dmax;
DumpFF2VTK([Sim_Path '/3D_Pattern.vtk'],E_far_normalized,thetaRange,phiRange,1e-3);



% s11  list of complex numbers, as per freq

filename = uiputfile("*.s?p", 'Save Touchstone File');
touchstonewrite(filename, ts);

pause();
