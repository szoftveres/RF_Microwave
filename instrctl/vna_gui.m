pkg load instrument-control

graphics_toolkit qt

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
    instrcmd_cmd(sp, ["asel " num2str(n)]);
end


function rfon(sp)
    pause on;
    instrcmd_cmd(sp, "rfon");
    pause(0.1);
end

function rfoff(sp)
    pause on;
    instrcmd_cmd(sp, "rfoff");
    pause(0.1);
end


function S = sweep_freq_meas (sp, sweep)
    S = [];
    pwr_avg = 0;
    avg_n = 0;
    ampl = 0;
    rfon(sp);
    for i = 1:length(sweep)
        [meas, refampl] = measure_vna_freq(sp, sweep(i));
        S = [S meas];
        pwr_avg += abs(meas);
        avg_n += 1;
        if (refampl > ampl)
            ampl = refampl;
        end
    end
    rfoff(sp);
    pwr_avg /= avg_n;
    if (ampl > 57344)
        printf("ref overload: %i\n", ampl);
    end
    if (pwr_avg > 1)
        printf("rx > ref: %.2f dB\n", 10 * log10(pwr_avg));
    end
end


function S = sweep_freq_meas_refl (sp, sweep)
    asel(sp, 1); % refl
    S = sweep_freq_meas (sp, sweep);
end


function S = sweep_freq_meas_thru (sp, sweep)
    asel(sp, 0); % thru
    S = sweep_freq_meas (sp, sweep);
end


function powerlevelchange(sp, level)
    pause on;
    instrcmd_cmd(sp, ["level " num2str(level)]);
    pause(0.2);
end


function mkr = markercalc(marker_khz, sweep)
    mkr = 1;

    for i = 1:length(sweep)
        if (sweep(i) >= marker_khz)
            mkr = i;
            break
        end
    end
end

%
% This function is called after a frequency (start, stop or step) change and
% re-calculates the sweep, and calkit parameters based on the current calkit
%
function [sweep, correction] = recalc_vna (config, Z0)
    sweep = config.startkhz:config.step_khz:config.stopkhz;
    correction.g_open = [];
    correction.g_short = [];
    correction.g_load = [];
    for i = 1:length(sweep)
        correction.g_open = [correction.g_open keysight_cal_open(Z0, (sweep(i)*1000),
                                                                 config.calkit.open(1),
                                                                 config.calkit.open(2),
                                                                 config.calkit.open(3),
                                                                 config.calkit.open(4),
                                                                 config.calkit.open(5),
                                                                 config.calkit.open(6),
                                                                 config.calkit.open(7))];
        correction.g_short = [correction.g_short keysight_cal_short(Z0, (sweep(i)*1000),
                                                                    config.calkit.short(1),
                                                                    config.calkit.short(2),
                                                                    config.calkit.short(3),
                                                                    config.calkit.short(4),
                                                                    config.calkit.short(5),
                                                                    config.calkit.short(6),
                                                                    config.calkit.short(7))];
        correction.g_load = [correction.g_load keysight_cal_load(Z0, (sweep(i)*1000),
                                                                    config.calkit.load(1),
                                                                    config.calkit.load(2),
                                                                    config.calkit.load(3),
                                                                    config.calkit.load(4))];
    end
end


%
% This function is called after a frequency (start, stop or step) change or at startup
% and invalidates + resets the calibration
%
function config = reset_cal (config, sweep)
    config.s_open = ones(length(sweep));
    config.s_short = ones(length(sweep)) * -1;
    config.s_load = zeros(length(sweep));
    config.s_iso = zeros(length(sweep));
    config.s_thru = ones(length(sweep));
    config.calstate = "-----";
end


%
% This function is called on startup and initializes the calkit
% with "ideal" parameters (HP / Keysight style)
%
function config = ideal_calkit (config)
    %                       delay       loss   z0
    %                       [s]         [w/s] [w]
    % open                                            c0,c1,c2,c3
    % short                                           l0,l1,l2,l3
    % load                                            r
    config.calkit.open =    [0,     0,     50,    1e-15, 0, 0, 0];
    config.calkit.short =   [0,     0,     50,    1e-12, 0, 0, 0];
    config.calkit.load =    [0,     0,     50,    50];
    config.calkit.thru =    [0,     0,     50];
end


% =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

%serialportlist("available")

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);


config.startkhz = 100000;
config.stopkhz =  5800000;
config.step_khz = 100000;

config.level = -15;
powerlevelchange(sp, config.level);

config = ideal_calkit(config);
[sweep, correction] = recalc_vna (config, Z0);
config = reset_cal(config, sweep);
config.mkr = floor(length(sweep)/2);

pause on;


function cb_open_cal (obj, init = false)
    fig = ancestor(obj,"figure","toplevel"); 
    action = get(fig, "userdata");
    action.opencal = 2;
    set(fig, "userdata", action);
end

function cb_short_cal (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.shortcal = 2;
    set(fig, "userdata", action);
end

function cb_load_cal (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.loadcal = 2;
    set(fig, "userdata", action);
end

function cb_iso_cal (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.isocal = 2;
    set(fig, "userdata", action);
end

function cb_thru_cal (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.thrucal = 2;
    set(fig, "userdata", action);
end

function cb_save_touchstone (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.save_touchstone = 2;
    set(fig, "userdata", action);
end

function cb_load_conf (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.load_conf = 2;
    set(fig, "userdata", action);
end

function cb_save_conf (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.save_conf = 2;
    set(fig, "userdata", action);
end

function cb_powerchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.powerchange = 2;
    set(fig, "userdata", action);
end

function cb_freqchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.freqchange = 2;
    set(fig, "userdata", action);
end

function cb_markerchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.markerchange = 2;
    set(fig, "userdata", action);
end

fig = figure(1,"position",get(0,"screensize"));
set (gcf, "color", get(0, "defaultuicontrolbackgroundcolor"));

posh = 0.85;
posv = 0.95;
uicontrol ("style", "text",
           "units", "normalized",
           "string", "Calibrate",
           "horizontalalignment", "left",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;

uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_open_cal,
           "string", "OPEN",
           "position", [posh posv 0.07 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_short_cal,
           "string", "SHORT",
           "position", [posh posv 0.07 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_load_cal,
           "string", "LOAD",
           "position", [posh posv 0.07 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_iso_cal,
           "string", "ISOL",
           "position", [posh posv 0.07 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_thru_cal,
           "string", "THRU",
           "position", [0.85 posv 0.07 0.04]); posv -= 0.05;
posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_save_touchstone,
           "string", "Export .s2p",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;

posh = 0.7;
posv = 0.95;
uicontrol ("style", "text",
           "units", "normalized",
           "string", "Set",
           "horizontalalignment", "left",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_freqchange,
           "string", "Freqency",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_powerchange,
           "string", "RF Level",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_markerchange,
           "string", "Marker",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;

uicontrol ("style", "text",
           "units", "normalized",
           "string", "Config",
           "horizontalalignment", "left",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;

uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_load_conf,
           "string", "Recall",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_save_conf,
           "string", "Save",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;




posv = 0.4;
conftext = uicontrol ("style", "text",
                      "units", "normalized",
                      "string", "Config:",
                      "horizontalalignment", "left",
                      "position", [posh posv 0.24 0.2]); posv -= 0.05;



posv = 0.1;
uicontrol ("style", "text",
           "units", "normalized",
           "string", "Messages:",
           "horizontalalignment", "left",
           "position", [posh posv 0.18 0.04]); posv -= 0.05;
msgbox = uicontrol ("style", "text",
                    "units", "normalized",
                    "backgroundcolor","white",
                    "string", "",
                    "horizontalalignment", "left",
                    "position", [posh posv 0.24 0.04]); posv -= 0.05;



set(fig, "userdata", config);
action.msg = "";

while true

    action.opencal = 0;
    action.shortcal = 0;
    action.loadcal = 0;
    action.isocal = 0;
    action.thrucal = 0;
    action.save_touchstone = 0;
    action.load_conf = 0;
    action.save_conf = 0;
    action.powerchange = 0;
    action.freqchange = 0;
    action.markerchange = 0;

    set(fig, "userdata", action);
    set(msgbox, "string", action.msg);
    set(conftext, "string", sprintf("Start: %i kHz\nStop: %i kHz\nStep: %i kHz\nPoints :%i\nLevel: %i dBm\nMarker: %i kHz\nCal: %s\n",
                                    config.startkhz, config.stopkhz, config.step_khz, length(sweep),
                                    config.level, sweep(config.mkr), config.calstate));

    %tic()
    s_11 = sweep_freq_meas_refl (sp, sweep);
    s_21 = sweep_freq_meas_thru (sp, sweep);
    %toc()
    ts = sweep2ts(sweep * 1000); % converting to Hz 

    for i = 1:length(sweep)

        % S1,1 error correction
        S11 = s_11(i);
        Scorr = zeros(2);
        Scorr(1,1) = p1cal(S11, config.s_open(i),
                                config.s_short(i),
                                config.s_load(i),
                                correction.g_open(i),
                                correction.g_short(i),
                                correction.g_load(i));

        % S2,1 error correction
        S21 = s_21(i);
        St = config.s_thru(i);
        Si = config.s_iso(i);
        Scorr(2,1) = conj((S21 - Si) / (St - Si));

        Scorr(1,2) = 1; % Scorr(2,1); % This makes s2abcd and abcd2s functions happy
        Scorr(2,2) = 0; % Scorr(1,1);
        ts.points(i).S = Scorr;
    end 

    plot2ports_fwd(ts, config.mkr);

    pause(0.1);

    action = get(fig, "userdata");

    if (action.save_touchstone > 0)
        filename = uiputfile({"*.s2p"});
        if (filename)
            touchstonewrite(filename, ts);
            action.msg = [filename " saved"];
        end
    elseif (action.freqchange > 0)
        ans = inputdlg({'Start (kHz)', 'Stop (kHz)', 'Step (kHz)'}, 'Frequency', 1, {config.startkhz, config.stopkhz, config.step_khz});
        if (!isempty(ans))
            startkhz = str2num(ans{1});
            config.startkhz = startkhz;
            stopkhz = str2num(ans{2});
            config.stopkhz = stopkhz;
            step_khz = str2num(ans{3});
            config.step_khz = step_khz;
            [sweep, correction] = recalc_vna (config, Z0);
            config = reset_cal(config, sweep);
            config.mkr = floor(length(sweep)/2);
            action.msg = sprintf("Cal reset");
        end
    elseif (action.powerchange > 0)
        ans = inputdlg({"Enter RF level (-30 dBm - 0 dBm)"}, "RF level", 1, {config.level});
        if (!isempty(ans))
            lev = str2num(ans{1});
            config.level = lev;
            powerlevelchange(sp, config.level);
            action.msg = sprintf("Level: %i dBm", config.level);
        end
    elseif (action.markerchange > 0)
        ans = inputdlg({"Enter new marker (kHz)"} , "Marker", 1, {sweep(config.mkr)});
        if (!isempty(ans))
            khz = str2num(ans{1});
            if ((khz < sweep(1)) || (khz > sweep(length(sweep))))
                action.msg = "ERROR: marker out of range";
            else
                config.mkr = markercalc(khz, sweep); 
                action.msg = sprintf("Marker: %i kHz", sweep(config.mkr));
            end
        end
    elseif (action.opencal > 0)
        config.s_open = sweep_freq_meas_refl (sp, sweep);
        config.calstate(1) = 'o';
        action.msg = "Open cal done";
    elseif (action.shortcal > 0)
        config.s_short = sweep_freq_meas_refl (sp, sweep);
        config.calstate(2) = 's';
        action.msg = "Short cal done";
    elseif (action.loadcal > 0)
        config.s_load = sweep_freq_meas_refl (sp, sweep);
        config.calstate(3) = 'l';
        action.msg = "Load cal done";
    elseif (action.isocal > 0)
        config.s_iso = sweep_freq_meas_thru (sp, sweep);
        config.calstate(4) = 'i';
        action.msg = "Iso cal done";
    elseif (action.thrucal > 0)
        config.s_thru = sweep_freq_meas_thru (sp, sweep);
        config.calstate(5) = 't';
        action.msg = "Thru cal done";
    elseif (action.save_conf > 0)
        filename = uiputfile("*.cfg");
        if (filename)
            save (sprintf ("%s", filename), "config")
            action.msg = [filename " saved"];
        end
    elseif (action.load_conf > 0)
        filename = uigetfile("*.cfg");
        if (filename)
            load(filename);
            [sweep, correction] = recalc_vna (config, Z0);
            powerlevelchange(sp, config.level);
            action.msg = "config recalled";
        end
    end

end



for i = 1:length(sweep)
    g_open = [g_open keysight_cal_open(Z0,
                                       (sweep(i)*1000),
                                       35.73e-12,
                                       2.87e9,
                                       50,
                                       -4.87e-15,
                                       -1140.3e-27,
                                       2176.5e-36,
                                       -213.5e-45)];
    g_short = [g_short keysight_cal_short(Z0,
                                       (sweep(i)*1000),
                                       31.6e-12,
                                       3.4e9,
                                       51.9,
                                       1e-42,
                                       0,              
                                       0,
                                       0)];
    g_load = [g_load keysight_cal_load(Z0,
                                       (sweep(i)*1000),
                                       76.6e-12,
                                       0,
                                       50,
                                       50.95)];
end


