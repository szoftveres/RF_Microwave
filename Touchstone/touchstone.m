% script display touchstone

graphics_toolkit qt

% port impedance
Z0 = 50;

% common functions
addpath("../RFlib")

[filename, folder] = uigetfile();
if (filename)
    f = fullfile(folder, filename);
    ts = touchstoneread(f);
    plot2ports(ts, 69)
    %touchstonewrite('out.s2p', ts)
    pause()
end


