
pkg load signal;

sync_channel = 2;
sample_channel = 1;


printf("\n\n == Reading data ..\n\n");

[audiofile, samplerate] = audioread("radartest_car_success3.wav");


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


% Processing
avg_subarray = zeros(1,subarray_size);
%window = ones(1,subarray_size);
window = rot90(hanning(subarray_size));

dataarray = [];
subarray = [];
for i=1:sweeps_counter
    subarray = sample(sweepstarts(i)+samples_to_skip_front:sweepstarts(i)+lowest_samples_per_sweep-samples_to_skip_back);
    subarray = abs(fft(subarray .* window));
    avg_subarray = avg_subarray + subarray;

    dataarray = [dataarray ; subarray];
end

avg_subarray = avg_subarray / sweeps_counter;


% Removing averaged background return
plotarray_timeslots = size(dataarray)(1);
plotarray = [];
for i=1:plotarray_timeslots
    subarray = dataarray(i,:);
    subarray = subarray - avg_subarray + 100;
    subarray = log10(subarray(1:subarray_size/6));
    plotarray = [plotarray ; subarray];
end


%subarray = subarray(1:subarray_size/6);
%subarray = abs(fft(subarray .* window)) - avg_subarray + 100;



plotarray_size = size(plotarray)


printf("\n\n == Plotting ..\n\n");

plotmin = min(min(plotarray));
plotmax = max(max(plotarray));
plotampl = (plotmax - plotmin);

plotmean = mean(mean(plotarray));

figure;
%colormap ("gray");
h = pcolor(flip(rot90(plotarray)));
set(h, 'EdgeColor', 'none');
caxis([(plotmean )      (plotmax - (plotampl * 0.20 ))]);
printf("Done\n");

pause();

