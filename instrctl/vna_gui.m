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

% =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

%serialportlist("available")

sp = serialport("/dev/ttyUSB0", 38400);
set(sp, 'timeout', 1);


config.startkhz = 100000;
config.stopkhz =  5800000;
config.step_khz = 100000;

sweep = config.startkhz:config.step_khz:config.stopkhz;
config.mkr = floor(length(sweep)/2);

config.level = -15;
powerlevelchange(sp, config.level);

config.s_open = ones(length(sweep));
config.s_short = ones(length(sweep)) * -1;
config.s_load = zeros(length(sweep));
config.s_iso = zeros(length(sweep));
config.s_thru = ones(length(sweep));




g_open = [];
g_short = [];
g_load = [];
for i = 1:length(sweep)
    g_open = [g_open 1];
    g_short = [g_short -1];
    g_load = [g_load 0];
end


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

function cb_startchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.startchange = 2;
    set(fig, "userdata", action);
end

function cb_stopchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.stopchange = 2;
    set(fig, "userdata", action);
end

function cb_stepchange (obj, init = false)
    fig = ancestor(obj,"figure","toplevel");
    action = get(fig, "userdata");
    action.stepchange = 2;
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


posv = 0.95;
uicontrol ("style", "text",
           "units", "normalized",
           "string", "Calibrate",
           "horizontalalignment", "left",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;

uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_open_cal,
           "string", "OPEN",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_short_cal,
           "string", "SHORT",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_load_cal,
           "string", "LOAD",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_iso_cal,
           "string", "ISOL",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_thru_cal,
           "string", "THRU",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;
posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_save_touchstone,
           "string", "Save .s2p",
           "position", [0.85 posv 0.12 0.04]); posv -= 0.05;

posh = 0.7;
posv = 0.95;
uicontrol ("style", "text",
           "units", "normalized",
           "string", "Set",
           "horizontalalignment", "left",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_startchange,
           "string", "Start",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_stopchange,
           "string", "Stop",
           "position", [posh posv 0.12 0.04]); posv -= 0.05;
uicontrol ("style", "pushbutton",
           "units", "normalized",
           "callback", @cb_stepchange,
           "string", "Step",
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




posv = 0.25;
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
    action.startchange = 0;
    action.stopchange = 0;
    action.stepchange = 0;
    action.markerchange = 0;

    set(fig, "userdata", action);
    set(msgbox, "string", action.msg);
    set(conftext, "string", sprintf("Start: %i kHz\nStop: %i kHz\nStep: %i kHz\nPoints :%i\nLevel: %i dBm\nMarker: %i kHz\n",
                                    config.startkhz, config.stopkhz, config.step_khz, length(sweep),
                                    config.level, sweep(config.mkr)));

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
                                g_open(i),
                                g_short(i),
                                g_load(i));

        % S2,1 error correction
        S21 = s_21(i);
        St = config.s_thru(i);
        Si = config.s_iso(i);
        Scorr(2,1) = conj((S21 - Si) / (St - Si));

        Scorr(1,2) = Scorr(2,1); % This makes s2abcd and abcd2s functions happy
        Scorr(2,2) = Scorr(1,1);
        ts.points(i).S = Scorr;
    end 

    plot2ports_fwd(ts, config.mkr);

    pause(0.1);

    action = get(fig, "userdata");

    if (action.save_touchstone > 0)
        filename = uiputfile("*.s?p");
        touchstonewrite(filename, ts);
        action.msg = [filename " saved"];
    elseif (action.powerchange > 0)
        ans = inputdlg("Enter RF level (-30 dBm - 0 dBm)" );
        lev = str2num(ans{1});
        config.level = lev;
        powerlevelchange(sp, config.level);
        action.msg = sprintf("Level: %i dBm", config.level);
    elseif (action.markerchange > 0)
        ans = inputdlg("Enter new marker (kHz)" );
        khz = str2num(ans{1});
        if ((khz < sweep(1)) || (khz > sweep(length(sweep))))
            action.msg = "ERROR: marker out of range";
        else
            config.mkr = markercalc(khz, sweep); 
            action.msg = sprintf("Marker: %i kHz", sweep(config.mkr));
        end
    elseif (action.opencal > 0)
        config.s_open = sweep_freq_meas_refl (sp, sweep);
        action.msg = "Open cal done";
    elseif (action.shortcal > 0)
        config.s_short = sweep_freq_meas_refl (sp, sweep);
        action.msg = "Short cal done";
    elseif (action.loadcal > 0)
        config.s_load = sweep_freq_meas_refl (sp, sweep);
        action.msg = "Load cal done";
    elseif (action.isocal > 0)
        config.s_iso = sweep_freq_meas_thru (sp, sweep);
        action.msg = "Iso cal done";
    elseif (action.thrucal > 0)
        config.s_thru = sweep_freq_meas_thru (sp, sweep);
        action.msg = "Thru cal done";
    elseif (action.save_conf > 0)
        filename = uiputfile("*.cfg");
        save (sprintf ("%s", filename), "config")
        action.msg = [filename " saved"];
    elseif (action.load_conf > 0)
        load(uigetfile("*.cfg"));
        sweep = config.startkhz:config.step_khz:config.stopkhz;
        g_open = [];
        g_short = [];
        g_load = [];
        for i = 1:length(sweep)
            g_open = [g_open 1];
            g_short = [g_short -1];
            g_load = [g_load 0];
        end
        powerlevelchange(sp, config.level);
        action.msg = "config recalled";
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


