
pkg load signal;

sync_channel = 2;
sample_channel = 1;


% 0: None
% 1: Average
edge_detect = 1;


% Post-equalization
% 0:off, value:magnitude difference between the two ends
post_eq = 0;


decimation_factor = 1;


% Logarithmic color representation (dynamic compression)
% 0:off, 1:on
log_color = 1;

printf("\n\n == Reading data ..\n\n");

[audiofile, samplerate] = audioread("radartest_car.wav");


samplerate

totalsamples = size(audiofile)(1)
recording_length_seconds = totalsamples / samplerate


% Separating the two (sync and sample) channels
sync = [];
sample = [];

sync = rot90(audiofile(:, sync_channel));
sample = rot90(audiofile(:, sample_channel));


printf("\n\n == Detecting sweeps ..\n\n");

sweeps = 0;
sweepstarts = [];
sweepends = [];
in_sweep = 0;


for i=2:totalsamples
    if (sync(i-1) < 0.12 && sync(i) > 0.12 && not(in_sweep))
        sweepstarts = [sweepstarts i];
        in_sweep = 1;
    endif
    if (sync(i-1) > -0.12 && sync(i) < -0.12 && in_sweep)
        sweepends = [sweepends i];
        sweeps = sweeps + 1;
        in_sweep = 0;
    endif
end

sweeps
sweeps_to_skip = 3
periodicity_of_sweeps_hz = sweeps / recording_length_seconds


sweepstarts = sweepstarts(sweeps_to_skip:sweeps-sweeps_to_skip);
sweepends = sweepends(sweeps_to_skip:sweeps-sweeps_to_skip);


% Calculating the number of samples within a sweep
sweeps_counter = 0;
lowest_samples_per_sweep = 9e+9;
highest_samples_per_sweep = 0;
average_samples_per_sweep = 0;
sweeps_counter = length(sweepstarts);
for i=1:sweeps_counter
    samples_per_sweep = sweepends(i) - sweepstarts(i);
    average_samples_per_sweep = average_samples_per_sweep + samples_per_sweep;
    lowest_samples_per_sweep = min(lowest_samples_per_sweep, samples_per_sweep);
    highest_samples_per_sweep = max(highest_samples_per_sweep, samples_per_sweep);
end


sweeps_counter
lowest_samples_per_sweep
average_samples_per_sweep = average_samples_per_sweep / sweeps_counter
highest_samples_per_sweep

printf("\n\n == Processing ..\n\n");

samples_to_skip_front = round(lowest_samples_per_sweep / 6)
samples_to_skip_back = round(lowest_samples_per_sweep / 20)


subarray_size = 1+lowest_samples_per_sweep-samples_to_skip_back-samples_to_skip_front


fft_base_Hz = samplerate / subarray_size

% Processing
window = ones(1,subarray_size);
window = rot90(hanning(subarray_size));

dataarray = [];
subarray = [];

for i=1:decimation_factor:sweeps_counter
    subarray = sample(sweepstarts(i)+samples_to_skip_front:sweepstarts(i)+lowest_samples_per_sweep-samples_to_skip_back);
    %subarray = abs(fft(subarray .* window));
    subarray = (fft(subarray .* window));

    if (post_eq)
        for eqi=1:subarray_size
            subarray(eqi) = subarray(eqi) * (1 + (eqi / subarray_size) * post_eq);
        end 
    endif
    dataarray = [dataarray ; subarray];
end


% Edge-detecting
plotarray_timeslots = size(dataarray)(1);
plotarray = [];
cat_subarray_size = floor(subarray_size/6);

for i=1:plotarray_timeslots
    subarray = dataarray(i,:);
    if (i >= 2)
        if (edge_detect)
            subarray = abs(subarray - dataarray(i-1,:));
            %subarray = (subarray - dataarray(i-1,:));
        endif
    endif
    subarray = subarray(1:cat_subarray_size);
    plotarray = [plotarray ; subarray];
end
plotarray = plotarray(2:end,:);
plotarray_size = size(plotarray)(1);
subarray_size = cat_subarray_size;


% Normalizing results

plotarray_normalized = [];

for i=1:plotarray_size
    subarray = plotarray(i,:);
    min_val = min(subarray);
    max_val = max(subarray);
    ampl = max_val - min_val;
    subarray = subarray - min_val;
    subarray = subarray / ampl;
    plotarray_normalized = [plotarray_normalized; subarray];
end

plotarray = plotarray_normalized;
plotarray = fft2(plotarray);
xstart=floor(plotarray_size/33);
for x=xstart:plotarray_size
    for y=1:subarray_size
        plotarray(x,y) = 0;
    end
end
plotarray = real(ifft2(plotarray));



printf("\n\n == Plotting ..\n\n");

figure;
h = pcolor(flip(rot90(plotarray)));
set(h, 'EdgeColor', 'none');


sweepspan_Hz = 30e6
c_meterpersec = 300e6
sweeptime_sec = average_samples_per_sweep / samplerate
sweepmagnitude_Hz_per_sec = sweepspan_Hz / sweeptime_sec

for i=10:10:100
    rack_freq = i * fft_base_Hz;
    time_of_flight_sec = rack_freq / sweepmagnitude_Hz_per_sec;
    roundtrip_meter = c_meterpersec * time_of_flight_sec;
    target_meter = roundtrip_meter/2;
    printf("    Y axis: %i  -   distance: %i m   -   echo %i Hz\n", i, target_meter, rack_freq);
    
end 


printf("\nDone.\n");

pause();

