pkg load instrument-control

%serialportlist("available")

% common functions
addpath("../RFlib");

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);

for i = 1:50
    instrcmd_u32sync(sp, ["instctltest " num2str(i)], 0xB43355AA);
    read(sp, 1, "int32")
end


