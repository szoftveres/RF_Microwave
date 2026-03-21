pkg load instrument-control

%serialportlist("available")

Z0 = 50 + 0j;

function rc = measure_vna_freq(sp, khz)
    instrcmd_u32sync(sp, ["vna " num2str(khz)], 0xB43355AA);
    ref_i = read(sp, 1, "int32");
    ref_q = read(sp, 1, "int32");
    meas_i = read(sp, 1, "int32");
    meas_q = read(sp, 1, "int32");
    ref = complex(ref_i, ref_q);
    meas = complex(meas_i, meas_q);
    rc = meas/ref;
end


%       0 - through,       1 - reflected
function asel(sp, n)
    pause on;
    instrcmd_cmd(sp, ["asel = " num2str(n)]);
    pause(0.2);
end


function ts = sweep_freq_meas_refl (sp, sweep, Z0)
    asel(sp, 1); % refl
    ts = sweep2ts(sweep * 1000); % converting to Hz
    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = measure_vna_freq(sp, sweep(i));
        S(2,1) = complex(1e-9, 1e-9);
        S(1,2) = complex(1e-9, 1e-9);
        S(2,2) = complex(1e-9, 1e-9);
        ts.points(i).ABCD = s2abcd(S, Z0);
    end
end


function ts = sweep_freq_meas_thru (sp, sweep, Z0)
    asel(sp, 0); % thru
    ts = sweep2ts(sweep * 1000); % converting to Hz
    for i = 1:length(sweep)
        S = zeros(2);
        S(1,1) = complex(1e-9, 1e-9);
        S(2,1) = measure_vna_freq(sp, sweep(i));
        S(1,2) = complex(1e-9, 1e-9);
        S(2,2) = complex(1e-9, 1e-9);
        ts.points(i).ABCD = s2abcd(S, Z0);
    end
end




function powerlevelchange(sp, level)
    pause on;
    instrcmd_cmd(sp, ["level = " num2str(level)]);
    pause(0.2);
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

config.startkhz = 350000;
config.stopkhz =  550000;
config.step_khz = 2500;

sweep = config.startkhz:config.step_khz:config.stopkhz;

config.mkr = floor(length(sweep)/2);

config.level = input ("Enter power level (-30 dBm - 0 dBm): " );

powerlevelchange(sp, config.level);


EXP = input("Connect OPEN ");
config.ts_open = sweep_freq_meas_refl (sp, sweep, Z0);

EXP = input("Connect SHORT ");
config.ts_short = sweep_freq_meas_refl (sp, sweep, Z0);

EXP = input("Connect LOAD ");
config.ts_load = sweep_freq_meas_refl (sp, sweep, Z0);

EXP = input("Connect THRU ");
config.ts_thru = sweep_freq_meas_thru (sp, sweep, Z0);


printf("\n");
printf(" [p]: Power change\n");
printf(" [m]: Marker change\n");
printf(" [o]: Calibrate OPEN\n");
printf(" [s]: Calibrate SHORT\n");
printf(" [l]: Calibrate LOAD\n");
printf(" [t]: Calibrate THRU\n");
printf(" [C]: Save CFG\n");
printf(" [c]: Load CFG\n");

pause on;

while true

    ts_11 = sweep_freq_meas_refl (sp, sweep, Z0);
    ts_21 = sweep_freq_meas_thru (sp, sweep, Z0);
    ts      = sweep2ts(sweep * 1000); % converting to Hz 

    for i = 1:length(sweep)
        S11 = abcd2s(ts_11.points(i).ABCD, Z0);

        So = abcd2s(config.ts_open.points(i).ABCD, Z0);
        Ss = abcd2s(config.ts_short.points(i).ABCD, Z0);
        Sl = abcd2s(config.ts_load.points(i).ABCD, Z0);
        Scorr = p1cal(S11, So, Ss, Sl, 1 - 1e-9, -(1 - 1e-9), complex(1e-9, 1e-9), Z0);

        S21 = abcd2s(ts_21.points(i).ABCD, Z0);

        St = abcd2s(config.ts_thru.points(i).ABCD, Z0);
        Scorr(2,1) = S21(2,1) / St(2,1);

        ts.points(i).ABCD = s2abcd(Scorr, Z0);
    end 

    plot2ports_fwd(ts, config.mkr);
    pause(0.2);
    c = kbhit(1);

    if (c == 'p')
        config.level = input ("Enter power level (-30 dBm - 0 dBm): " );
        powerlevelchange(sp, config.level);
    elseif (c == 'm')
        config.mkr = markerchange(sweep); 
    elseif (c == 'o')
        EXP = input("Connect OPEN ");
        config.ts_open = sweep_freq_meas_refl (sp, sweep, Z0);
    elseif (c == 's')
        EXP = input("Connect SHORT ");
        config.ts_short = sweep_freq_meas_refl (sp, sweep, Z0);
    elseif (c == 'l')
        EXP = input("Connect LOAD ");
        config.ts_load = sweep_freq_meas_refl (sp, sweep, Z0);
    elseif (c == 't')
        EXP = input("Connect THRU ");
        config.ts_thru = sweep_freq_meas_thru (sp, sweep, Z0);
    elseif (c == 'C')
        save "config.cfg" config
    elseif (c == 'c')
        load("config.cfg");
        sweep = config.startkhz:config.step_khz:config.stopkhz;
        powerlevelchange(sp, config.level);
        config.level
    end

end

