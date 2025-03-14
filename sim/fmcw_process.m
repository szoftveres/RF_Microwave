
pkg load signal;

sync_channel = 2;
sample_channel = 1;



% Functions to detect sweep start and sweep end

function retval = sweepstart(previous, current)
    retval = 0;
    if (current > 0.12 && previous < 0.12)
        retval = 1;
    endif
end

function retval = sweepend(previous, current)
    retval = 0;
    if (previous > -0.12 && current < -0.12)
        retval = 1;
    endif
end


printf("\n\n == Reading data ..\n\n");

% Reading in the file

[audiofile, samplerate] = audioread("radartest_car_success2.wav");


samplerate

totalsamples = size(audiofile)(1)
recording_length_seconds = totalsamples / samplerate


% Separating the two (sync and sample) channels
sync = [];
sample = [];
%for i=1:totalsamples
%    sync = [sync audiofile(i,sync_channel)];
%    sample = [sample audiofile(i,sample_channel)];
%end

sync = rot90(audiofile(:, sync_channel));
sample = rot90(audiofile(:, sample_channel));


printf("\n\n == Detecting sweeps ..\n\n");

% Calculating the total number of sweeps
sweeps = 0;
for i=2:totalsamples
    if (sweepstart(sync(i-1), sync(i)))
        sweeps = sweeps + 1;
    endif
end

sweeps
sweeps_to_skip = sweeps / 60
periodicity_of_sweeps_hz = sweeps / recording_length_seconds


% Calculating the number of samples within a sweep
sweepnumber = 0;
samples_per_sweep = 0;
sweeps_counted = 0;
lowest_samples_per_sweep = 9e+9;
highest_samples_per_sweep = 0;
average_samples_per_sweep = 0;
for i=2:totalsamples
    if (sweepstart(sync(i-1), sync(i)))
        sweepnumber = sweepnumber + 1;
        samples_per_sweep = 0;
    endif

    if (sweepnumber < sweeps_to_skip || sweepnumber > sweeps-sweeps_to_skip)
        % Skipping the first and last couple of sweeps
        continue;
    endif

    samples_per_sweep = samples_per_sweep + 1;

    if (sweepend(sync(i-1), sync(i)))
        sweeps_counted = sweeps_counted + 1;
        average_samples_per_sweep = average_samples_per_sweep + samples_per_sweep;
        lowest_samples_per_sweep = min(lowest_samples_per_sweep, samples_per_sweep);
        highest_samples_per_sweep = max(highest_samples_per_sweep, samples_per_sweep);
    endif

end

sweeps_counted
lowest_samples_per_sweep
average_samples_per_sweep = average_samples_per_sweep / sweeps_counted
highest_samples_per_sweep


printf("\n\n == Analyzing sweeps ..\n\n");

samples_to_skip_front = round(lowest_samples_per_sweep / 6)
samples_to_skip_back = round(lowest_samples_per_sweep / 20)


subarray_size = 1+lowest_samples_per_sweep-samples_to_skip_back-samples_to_skip_front

% Background noise calc
avg_subarray = zeros(1,subarray_size);
window = rot90(blackman(subarray_size));

sweepnumber = 0;
for i=2:totalsamples
    if (sweepstart(sync(i-1), sync(i)))
        sweepnumber = sweepnumber + 1;
        if (sweepnumber < sweeps_to_skip || sweepnumber > sweeps-sweeps_to_skip)
            % Skipping the first and last couple of sweeps
            continue;
        endif
        subarray = sample(i+samples_to_skip_front:i+lowest_samples_per_sweep-samples_to_skip_back);
        subarray = abs(dct(subarray .* window));
        avg_subarray = avg_subarray + subarray;
    endif
end

avg_subarray = avg_subarray / sweeps_counted;


% Frequency analysis
plotarray = [];
subarray = [];
sweepnumber = 0;
for i=2:totalsamples
    if (sweepstart(sync(i-1), sync(i)))
        sweepnumber = sweepnumber + 1;
        if (sweepnumber < sweeps_to_skip || sweepnumber > sweeps-sweeps_to_skip)
            % Skipping the first and last couple of sweeps
            continue;
        endif
        subarray = sample(i+samples_to_skip_front:i+lowest_samples_per_sweep-samples_to_skip_back);
        
        subarray = abs(dct(subarray .* window)) - avg_subarray + 100;

        subarray = subarray(1:subarray_size/4);
        plotarray = [plotarray ; log10(subarray)];
    endif
end


plotarray_size = size(plotarray)



%for i=1:samples:size(p)(2)-1
%    subarray = fft(p(i+1:i+samples-2))(samples/2:samples-2);
%    subarray = dct(p(i+1:i+samples-2));
%    plotarray = [plotarray ; log10(abs(subarray))];
%end

plotmin = min(min(plotarray))
plotmax = max(max(plotarray))
plotmag = (plotmax - plotmin) / 4;



figure;
%colormap ("gray");
h = pcolor(flip(rot90(plotarray)));
set(h, 'EdgeColor', 'none');
caxis([plotmin+plotmag plotmax-plotmag]);
printf("Done\n");

pause();

