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

function ts = measurement (sp, sweep, Z0)
    ts = sweep2ts(sweep * 1000); % converting to Hz
    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = measure_freq(sp, sweep(i));
        S(2,1) = 1e-9;
        S(1,2) = 1e-9;
        S(2,2) = 1e-9;
        ts.points(i).ABCD = s2abcd(S, Z0);
    end
end


% common functions
addpath("../RFlib");

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);

startkhz = 350000;
stopkhz =  550000;
step_khz = 2500;

sweep = startkhz:step_khz:stopkhz;

mkr = floor(length(sweep)/2);

level = powerlevelchange(sp);


EXP = input("Connect OPEN ");
ts_open = measurement (sp, sweep, Z0);

EXP = input("Connect SHORT ");
ts_short = measurement (sp, sweep, Z0);

EXP = input("Connect LOAD ");
ts_load = measurement (sp, sweep, Z0);


printf("\n");
printf(" [p]: Power change\n");
printf(" [m]: Marker change\n");
printf(" [o]: Calibrate OPEN\n");
printf(" [s]: Calibrate SHORT\n");
printf(" [l]: Calibrate LOAD\n");

pause on;

while true

    ts = sweep2ts(sweep * 1000); % converting to Hz
    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = measure_freq(sp, sweep(i));
        S(2,1) = 1e-9;
        S(1,2) = 1e-9;
        S(2,2) = 1e-9;

        So = abcd2s(ts_open.points(i).ABCD, Z0);
        Ss = abcd2s(ts_short.points(i).ABCD, Z0);
        Sl = abcd2s(ts_load.points(i).ABCD, Z0);
        S11 = p1cal(S, So, Ss, Sl, 1 - 1e-9, -(1 - 1e-9), 1e-9, Z0);
        ts.points(i).ABCD = s2abcd(S11, Z0);
    end
    plot1port(ts, mkr);
    pause(0.2);
    c = kbhit(1);

    if (c == 'p')
        level = powerlevelchange(sp);
    elseif (c == 'm')
        mkr = markerchange(sweep); 
    elseif (c == 'o')
        EXP = input("Connect OPEN ");
        ts_open = measurement (sp, sweep, Z0);
    elseif (c == 's')
        EXP = input("Connect SHORT ");
        ts_short = measurement (sp, sweep, Z0);
    elseif (c == 'l')
        EXP = input("Connect LOAD ");
        ts_load = measurement (sp, sweep, Z0);
    end

end

