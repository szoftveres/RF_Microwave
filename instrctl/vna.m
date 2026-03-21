pkg load instrument-control

%serialportlist("available")

Z0 = 50 + 0j;


function rc = measure_freq(sp, khz)
    instrcmd_u32sync(sp, ["vna " num2str(khz)], 0xB43355AA);
    ref_i = read(sp, 1, "int32");
    ref_q = read(sp, 1, "int32");
    meas_i = read(sp, 1, "int32");
    meas_q = read(sp, 1, "int32");
    ref = complex(ref_i, ref_q);
    meas = complex(meas_i, meas_q);
    rc = meas/ref;
end


function level = powerlevelchange(sp)
    ans = input ("Enter power level (-30 dBm - 0 dBm): " );
    instrcmd_cmd(sp, ["level = " num2str(ans)]);
    level = ans;
end


function mkr = markerchange(sweep)
    mkr = 1;

    marker_khz = input ("Enter marker (kHz): " );

    if ((marker_khz < sweep(1)) || (marker_khz > sweep(length(sweep))))
        disp( 'Marker out of range' );
        return
    end
    
    for i = 1:length(sweep)
        if (sweep(i) >= marker_khz)
            mkr = i;
            break
        end
    end
end


% common functions
addpath("../RFlib");

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);

startkhz = 25000;
stopkhz =  200000;
step_khz = 5000;

marker_khz = 100000;

if ((marker_khz < startkhz) || (marker_khz > stopkhz))
    disp( 'Marker out of range' );
    return
end

sweep = startkhz:step_khz:stopkhz;

mkr = markerchange(sweep);

level = powerlevelchange(sp);

EXP = input("Connect OPEN ");
ts_open = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i));
    S(2,1) = 1e-9;
    S(1,2) = 1e-9;
    S(2,2) = 1e-9;
    ts_open.points(i).ABCD = s2abcd(S, Z0);
end


EXP = input("Connect SHORT ");
ts_short = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i));
    S(2,1) = 1e-9;
    S(1,2) = 1e-9;
    S(2,2) = 1e-9;
    ts_short.points(i).ABCD = s2abcd(S, Z0);
end

EXP = input("Connect LOAD ");
ts_match = sweep2ts(sweep * 1000); % converting to Hz
for i = 1:length(sweep)
    S = zeros(2);
    S(1,1) = measure_freq(sp, sweep(i));
    S(2,1) = 1e-9;
    S(1,2) = 1e-9;
    S(2,2) = 1e-9;
    ts_match.points(i).ABCD = s2abcd(S, Z0);
end



printf("\n");
printf("Power change: (p)\n");
printf("Marker change: (m)\n");

pause on;

while true

    sweep = startkhz:step_khz:stopkhz;
    ts = sweep2ts(sweep * 1000); % converting to Hz

    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = measure_freq(sp, sweep(i));
        S(2,1) = 1e-9;
        S(1,2) = 1e-9;
        S(2,2) = 1e-9;

        So = abcd2s(ts_open.points(i).ABCD, Z0);
        Ss = abcd2s(ts_short.points(i).ABCD, Z0);
        Sm = abcd2s(ts_match.points(i).ABCD, Z0);
        S11 = p1cal(S, So, Ss, Sm, 1 - 1e-9, -(1 - 1e-9), 1e-9, Z0);
        ts.points(i).ABCD = s2abcd(S11, Z0);
    end
    plot1port(ts, mkr);
    pause(0.2);
    c = kbhit(1);

    if (c == 'p')
        level = powerlevelchange(sp);
    elseif (c == 'm')
        mkr = markerchange(sweep); 
    end

end

