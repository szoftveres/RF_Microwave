
addpath('/home/mk/tmp/RF_Microwave/OpenEMS/openems/share/openEMS/matlab')
addpath('/home/mk/tmp/RF_Microwave/OpenEMS/openems/share/CSXCAD/matlab')

addpath("../../RFlib");

close all
clear
clc

%%
physical_constants;
unit = 1e-3;


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

% setup FDTD parameter & excitation function
f0 = 83.5e9; % center frequency
max_recursion_depth(2048)
fc = 10e9; % 20 dB corner frequency, 150MHz originally

TE_mode = 'TE10';


CSX = InitCSX();

CSX = AddMetal(CSX,'copper');
CSX = AddMaterial(CSX, 'air');
CSX = SetMaterialProperty(CSX, 'air', 'Epsilon', 1, 'Mue', 1);

alumina.losst = 0.01; 
alumina.epsR   = 9.3;
alumina.kappa  = alumina.losst * 2*pi*f0 * EPS0*alumina.epsR;
CSX = AddMaterial(CSX, 'alumina');
CSX = SetMaterialProperty(CSX, 'alumina', 'Epsilon', alumina.epsR, 'Kappa', alumina.kappa);



waveguide.x = 3.10;             % WR12 a
waveguide.y = waveguide.x / 2;  % WR12 b

window.length = 0.254;
cavity.radius = waveguide.x / sqrt(2);
cavity.wavelength = ((c0 / f0) / unit);   % Length of a full wave in vacuum

window.wavelength = (((c0 / f0) / unit) / sqrt(alumina.epsR));  % Length of a full wave in alumina
window.wave_portion = (window.length / window.wavelength);
window.radius = cavity.radius + (window.wavelength * 3/4) - window.length;

cavity.length = (cavity.wavelength * 3/4) - (cavity.wavelength * window.wave_portion);

x = (window.radius + 0.2) * 2;
y = (window.radius + 0.2) * 2;
z = 8;


% Big copper slab
start = [(-x/2)  (-y/2)  (-z/2)];
stop  = start + [ (x)  (y)  (z)];
CSX = AddBox( CSX, 'copper', 10, start, stop );

% Waveguide
start = [(-waveguide.x/2)  (-waveguide.y/2)  (-z/2)];
stop  = start + [ (waveguide.x)  (waveguide.y)  (z)];
CSX = AddBox( CSX, 'air', 30, start, stop );

% Pillbox cavity
start = [(0) (0) (-cavity.length/2)];
stop = start + [(0) (0) (cavity.length)];
CSX = AddCylinder(CSX, 'air', 30, start, stop, cavity.radius);

% Alumina window
start = [(0) (0) (-window.length/2)];
stop = start + [(0) (0) (window.length)];
CSX = AddCylinder(CSX, 'alumina', 40, start, stop, window.radius);


FDTD = InitFDTD('NrTS',  160000, 'EndCriteria', 1e-4); % -40 dB
FDTD = SetGaussExcite( FDTD, f0, fc );
BC = {'PEC' 'PEC' 'PEC' 'PEC' 'PML_8' 'PML_8'}; % boundary conditions
FDTD = SetBoundaryCond( FDTD, BC );

mesh.x = [(-x/2) (x/2)];
mesh.y = [(-y/2) (y/2)];
mesh.z = [(-z/2) (z/2)];

mesh = DetectEdges(CSX, mesh);
mesh = SmoothMesh(mesh, c0 / (f0+fc) / unit / 80);
CSX = DefineRectGrid(CSX, unit, mesh);


% Ports are in the form of a box with the excitation plane located at the start position and the voltage and current probes located at the stop position. The stop position specifies the reference plane for the port. 
% PML_8 Warning: In openEMS the last x lines in the respective direction are defined as this artificial absorbing material: Keep your structures far enough away!
start = [(-waveguide.x/2)  (-waveguide.y/2)  (mesh.z(10))];
stop  = [ (waveguide.x/2)  (waveguide.y/2)   (mesh.z(15))];
[CSX, port{1}] = AddRectWaveGuidePort( CSX, 90, 1, start, stop, 'z', waveguide.x*unit, waveguide.y*unit, TE_mode, 1);

start = [(-waveguide.x/2)  (-waveguide.y/2)  (mesh.z(end-10))];
stop  = [ (waveguide.x/2)  (waveguide.y/2)   (mesh.z(end-15))];
[CSX, port{2}] = AddRectWaveGuidePort( CSX, 90, 2, start, stop, 'z', waveguide.x*unit, waveguide.y*unit, TE_mode);


  
efield_z_dump_start = [(-x/2) (-y/2) 0];
efield_z_dump_stop = [(x/2) (y/2) 0];
CSX = AddDump(CSX,'Efield_z','DumpType', 0, 'DumpMode', 2);     %% Time domain efield
CSX = AddBox(CSX, 'Efield_z', 1, efield_z_dump_start, efield_z_dump_stop);

hfield_dump_start = [(-waveguide.x/2) 0 (-z/2)];
hfield_dump_stop = [(waveguide.x/2) 0 (z/2)];
CSX = AddDump(CSX,'Hfield','DumpType', 1, 'DumpMode', 2);     %% Time domain hfield
CSX = AddBox(CSX, 'Hfield', 1, hfield_dump_start, hfield_dump_stop);

% prepare simulation folder
Sim_Path = 'tmp_PILLBOX';
Sim_CSX = 'PILLBOX.xml';

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


%%
RunOpenEMS(Sim_Path, Sim_CSX)
%%
freq = linspace( f0-fc, f0+fc, 201 );
port = calcPort(port, Sim_Path, freq);

s11 = port{1}.uf.ref./ port{1}.uf.inc;
s21 = port{2}.uf.ref./ port{1}.uf.inc;
f_res_ind = find(s11==min(s11));

ts = sweep2ts(freq);

for fp = 1:length(freq)
    ts.points(fp).f = freq(fp);
    ts.points(fp).S(1,1) = s11(fp);
    ts.points(fp).S(2,1) = s21(fp);
end

plot2ports_fwd(ts, f_res_ind);

drawnow

pause();
pause();

