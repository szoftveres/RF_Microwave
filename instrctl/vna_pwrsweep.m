pkg load instrument-control

Z0 = 50 + 0j;

% common functions
addpath("../RFlib");

function [meas, refampl] = measure_vna_freq(sp, khz)
    instrcmd_u32sync(sp, ["vna " num2str(khz) "\n"], 0xB43355AA);
    ref_i = read(sp, 1, "int32");
    ref_q = read(sp, 1, "int32");
    refampl = read(sp, 1, "int32");
    meas_i = read(sp, 1, "int32");
    meas_q = read(sp, 1, "int32");
    ref = complex(ref_i, ref_q);
    rec = complex(meas_i, meas_q);
    meas = rec/ref;
end


%       0 - through,       1 - reflected
function asel(sp, n)
    pause on;
    instrcmd_cmd(sp, ["asel = " num2str(n)]);
end


function rfon(sp)
    pause on;
    instrcmd_cmd(sp, "rfon");
    pause(0.2);
end

function rfoff(sp)
    pause on;
    instrcmd_cmd(sp, "rfoff");
    pause(0.2);
end

function powerlevelchange(sp, level)
    pause on;
    instrcmd_cmd(sp, ["level = " num2str(level)]);
    pause(0.1);
end



function [S, pwr_avg, ampl] = sweep_freq_meas (sp, sweep, f)
    S = [];
    pwr_avg = 0;
    avg_n = 0;
    ampl = 0;
    rfon(sp);
    for i = 1:length(sweep)
        powerlevelchange(sp, sweep(i));

        [meas, refampl] = measure_vna_freq(sp, f);
        S = [S meas];
        pwr_avg += abs(meas);
        avg_n += 1;
        if (refampl > ampl)
            ampl = refampl;
        end
    end
    rfoff(sp);
    pwr_avg /= avg_n;
end


function S = sweep_freq_meas_refl (sp, sweep, f)
    asel(sp, 1); % refl
    [S, pwr_avg, ampl] = sweep_freq_meas (sp, sweep, f);
    % printf("rfl ampl: %i, %.2f dB\n", ampl, 10 * log10(pwr_avg));
end


function S = sweep_freq_meas_thru (sp, sweep, f)
    asel(sp, 0); % thru
    [S, pwr_avg, ampl] = sweep_freq_meas (sp, sweep, f);
    % printf("thru ampl: %i, %.2f dB\n", ampl, 10 * log10(pwr_avg));
end



% =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

%serialportlist("available")

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);

config.start = -30;
config.stop = 0;
config.step = 1;

sweep = config.start:config.step:config.stop;

config.mkr = floor(length(sweep)/2);

config.khz = input ("Enter frequency (kHz): " );


EXP = input("Connect OPEN ");
config.s_open = sweep_freq_meas_refl (sp, sweep, config.khz);

EXP = input("Connect SHORT ");
config.s_short = sweep_freq_meas_refl (sp, sweep, config.khz);

EXP = input("Connect LOAD ");
config.s_load = sweep_freq_meas_refl (sp, sweep, config.khz);

EXP = input("Connect ISOLATION ");
config.s_iso = sweep_freq_meas_thru (sp, sweep, config.khz);

EXP = input("Connect THRU ");
config.s_thru = sweep_freq_meas_thru (sp, sweep, config.khz);

printf("\n");
printf(" [f]: Frequency change\n");
printf(" [m]: Marker change\n");
printf(" [o]: Calibrate OPEN\n");
printf(" [s]: Calibrate SHORT\n");
printf(" [l]: Calibrate LOAD\n");
printf(" [i]: Calibrate ISOLATION\n");
printf(" [t]: Calibrate THRU\n");
printf(" [C]: Save CFG\n");
printf(" [c]: Load CFG\n");

pause on;

while true

    s_11 = sweep_freq_meas_refl (sp, sweep, config.khz);
    s_21 = sweep_freq_meas_thru (sp, sweep, config.khz);
    ps      = sweep2ts(sweep * 1000); % converting to Hz 

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
        ps.points(i).S = Scorr;
        ps.points(i).p = sweep(i);
    end 

    plotpwrsweep(ps);
    pause(0.2);
    c = kbhit(1);

    if (c == 'f')
        config.khz = input ("Enter frequency (kHz): " );
    elseif (c == 'o')
        EXP = input("Connect OPEN ");
        config.s_open = sweep_freq_meas_refl (sp, sweep, config.khz);
    elseif (c == 's')
        EXP = input("Connect SHORT ");
        config.s_short = sweep_freq_meas_refl (sp, sweep, config.khz);
    elseif (c == 'l')
        EXP = input("Connect LOAD ");
        config.s_load = sweep_freq_meas_refl (sp, sweep, config.khz);
    elseif (c == 'i')
        EXP = input("Connect ISOLATION ");
        config.s_iso = sweep_freq_meas_thru (sp, sweep, config.khz);
    elseif (c == 't')
        EXP = input("Connect THRU ");
        config.s_thru = sweep_freq_meas_thru (sp, sweep, config.khz);
    elseif (c == 'C')
        save "config_pwrsweep.cfg" config
    elseif (c == 'c')
        load("config_pwrsweep.cfg");
        sweep = config.start:config.step:config.stop;
    end

end

