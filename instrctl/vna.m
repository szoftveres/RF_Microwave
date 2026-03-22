pkg load instrument-control

%serialportlist("available")

Z0 = 50 + 0j;

function rc = measure_vna_freq(sp, khz)
    instrcmd_u32sync(sp, ["vna " num2str(khz) "\n"], 0xB43355AA);
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


function S = sweep_freq_meas_refl (sp, sweep)
    asel(sp, 1); % refl
    S = [];
    for i = 1:length(sweep)
        S = [S measure_vna_freq(sp, sweep(i))];
    end
end


function S = sweep_freq_meas_thru (sp, sweep)
    asel(sp, 0); % thru
    S = [];
    for i = 1:length(sweep)
        S = [S measure_vna_freq(sp, sweep(i))];
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

config.startkhz = 500000;
config.stopkhz =  5500000;
config.step_khz = 200000;

sweep = config.startkhz:config.step_khz:config.stopkhz;

config.mkr = floor(length(sweep)/2);

config.level = input ("Enter power level (-30 dBm - 0 dBm): " );

powerlevelchange(sp, config.level);


EXP = input("Connect OPEN ");
config.s_open = sweep_freq_meas_refl (sp, sweep);

EXP = input("Connect SHORT ");
config.s_short = sweep_freq_meas_refl (sp, sweep);

EXP = input("Connect LOAD ");
config.s_load = sweep_freq_meas_refl (sp, sweep);

EXP = input("Connect THRU ");
config.s_thru = sweep_freq_meas_thru (sp, sweep);

EXP = input("Connect ISOLATION ");
config.s_iso = sweep_freq_meas_thru (sp, sweep);

printf("\n");
printf(" [p]: Power change\n");
printf(" [m]: Marker change\n");
printf(" [o]: Calibrate OPEN\n");
printf(" [s]: Calibrate SHORT\n");
printf(" [l]: Calibrate LOAD\n");
printf(" [t]: Calibrate THRU\n");
printf(" [i]: Calibrate ISOLATION\n");
printf(" [C]: Save CFG\n");
printf(" [c]: Load CFG\n");

pause on;

while true

    s_11 = sweep_freq_meas_refl (sp, sweep);
    s_21 = sweep_freq_meas_thru (sp, sweep);
    ts      = sweep2ts(sweep * 1000); % converting to Hz 

    for i = 1:length(sweep)

        % S1,1 error correction
        S11 = s_11(i);
        So = config.s_open(i);
        Ss = config.s_short(i);
        Sl = config.s_load(i);
        Scorr = zeros(2);
        Scorr(1,1) = p1cal(S11, So, Ss, Sl, 1, -1, 0);

        % S2,1 error correction
        S21 = s_21(i);
        St = config.s_thru(i);
        Si = config.s_iso(i);
        Scorr(2,1) = conj((S21 - Si) / (St - Si));

        Scorr(1,2) = 1; % This makes s2abcd and abcd2s functions happy
        Scorr(2,2) = 0;
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
        config.s_open = sweep_freq_meas_refl (sp, sweep);
    elseif (c == 's')
        EXP = input("Connect SHORT ");
        config.s_short = sweep_freq_meas_refl (sp, sweep);
    elseif (c == 'l')
        EXP = input("Connect LOAD ");
        config.s_load = sweep_freq_meas_refl (sp, sweep);
    elseif (c == 't')
        EXP = input("Connect THRU ");
        config.s_thru = sweep_freq_meas_thru (sp, sweep);
    elseif (c == 'i')
        EXP = input("Connect ISOLATION ");
        config.s_iso = sweep_freq_meas_thru (sp, sweep);
    elseif (c == 'C')
        save "config.cfg" config
    elseif (c == 'c')
        load("config.cfg");
        sweep = config.startkhz:config.step_khz:config.stopkhz;
        powerlevelchange(sp, config.level);
        config.level
    end

end

