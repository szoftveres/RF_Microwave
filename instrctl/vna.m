pkg load instrument-control

%serialportlist("available")

Z0 = 50 + 0j;

% common functions
addpath("../RFlib");

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);

startkhz = 885000;
stopkhz =  945000;
step_khz = 1000;

attenuator = 10;


function rc = measure_freq(sp, khz, attenuator)
    instrcmd_u32sync(sp, ["vna " num2str(khz) " " num2str(attenuator)], 0xB43355AA);
    ref_i = read(sp, 1, "int32");
    ref_q = read(sp, 1, "int32");
    meas_i = read(sp, 1, "int32");
    meas_q = read(sp, 1, "int32");
    ref = complex(ref_i, ref_q);
    meas = complex(meas_i, meas_q);
    rc = meas/ref;
end



sweep = startkhz:step_khz:stopkhz;

EXP = input("Connect OPEN");
ts_open = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i), 10);
    S(2,1) = 1.01e-6;
    S(1,2) = 1.02e-6;
    S(2,2) = 1.03e-6;
    ts_open.points(i).ABCD = s2abcd(S, Z0);
end


EXP = input("Connect SHORT");
ts_short = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i), 10);
    S(2,1) = 1.04e-6;
    S(1,2) = 1.05e-6;
    S(2,2) = 1.06e-6;
    ts_short.points(i).ABCD = s2abcd(S, Z0);
end

EXP = input("Connect MATCH");
ts_match = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i), 10);
    S(2,1) = 1.04e-6;
    S(1,2) = 1.05e-6;
    S(2,2) = 1.06e-6;
    ts_match.points(i).ABCD = s2abcd(S, Z0);
end

pause on;

while true

    sweep = startkhz:step_khz:stopkhz;
    ts = sweep2ts(sweep * 1000); % converting to Hz

    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = measure_freq(sp, sweep(i), 10);
        S(2,1) = 1e-6;
        S(1,2) = 1e-6;
        S(2,2) = 1e-6;

        So = abcd2s(ts_open.points(i).ABCD, Z0);
        Ss = abcd2s(ts_short.points(i).ABCD, Z0);
        Sm = abcd2s(ts_match.points(i).ABCD, Z0);
        S11 = p1cal(S, So, Ss, Sm, 0.9999, -0.9998, 1.11e-9, Z0);
        ts.points(i).ABCD = s2abcd(S11, Z0);
    end
    plot1port(ts);
    pause(0.2);

end

