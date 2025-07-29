pkg load signal;

arraydim_x = 384
arraydim_y = 64



scenery = zeros(arraydim_y, arraydim_x);

for x = 32:48
    scenery(10, x + 64) = 2;
    scenery(11, x + 64) = 2;
    
    scenery(15, x + 240) = 2;
    scenery(16, x + 240) = 2;
    
    scenery(32, x + 128) = 2;
    scenery(33, x + 128) = 2;

    scenery(x, 256-x*4) = 2;
end

scenery(48, 360) = 2;



% ==============================


y_dist_m = 5;                                   % 5m per pixel
x_speed_mps = 15.64;                            % 35mph
x_repetition_rate = 5 ;                         % radar 5Hz -> need to decimate from 100 to 5
x_dist_m = x_speed_mps / x_repetition_rate      % distance between two consecutive sweeps (locations)
xy_ratio = x_dist_m / y_dist_m




scan_locations = 1:arraydim_x;

length(scan_locations)

echoarray = zeros(arraydim_y, length(scan_locations));


window = (gausswin(arraydim_y * 2) .* gausswin(arraydim_y * 2));


nloc = 1;
for loc = scan_locations
    loc
    for dist = 1:arraydim_y-1  % this is in 5m / pixel
        for x = round(loc-(dist/xy_ratio)-1) : round(loc+(dist/xy_ratio)+1)    % this is in 0.16m / pixel
            if ((x < 1) || (x > arraydim_x))
                continue;
            end
            corrected_lateral_dist = abs(x-loc) * xy_ratio;
            for y = 1 : dist+1
                if round(sqrt(corrected_lateral_dist ^ 2 + y ^ 2)) == dist
                    echoarray(dist, nloc) += (scenery(y, x) * window(round(corrected_lateral_dist + arraydim_y)));
%                    scenery(y, x) = 10 * window(round(abs(x-loc) * xy_ratio) + arraydim_y);
                endif
            end
        end
    end
    nloc += 1;
end


figure;
h = pcolor(log10(echoarray));
title("echo array");
xlabel("antenna location");
ylabel("range");
set(h, 'EdgeColor', 'none');

figure;
h = pcolor(scenery);
title("scenery");
xlabel("lateral dim");
ylabel("range dim");
set(h, 'EdgeColor', 'none');


% ===============================================

%plotarray = ones(arraydim_y, arraydim_x);
plotarray = zeros(arraydim_y, length(scan_locations));

nloc = 1;
for loc = scan_locations
    loc
    for dist = 1:arraydim_y-1  % this is in 5m / pixel
        for x = round(loc-(dist/xy_ratio)-1) : round(loc+(dist/xy_ratio)+1)    % this is in 0.16m / pixel
            if ((x < 1) || (x > arraydim_x))
                continue;
            end
            corrected_lateral_dist = abs(x-loc) * xy_ratio;
            for y = 1 : dist+1
                if round(sqrt(corrected_lateral_dist ^ 2 + y ^ 2)) == dist
                    plotarray(y,x) += (echoarray(dist, nloc) * window(round(corrected_lateral_dist + arraydim_y)));
                endif
            end
        end
    end
    nloc += 1;
end


%plotarray = log10(plotarray);


save "plotarray.txt" plotarray


printf("\nDone.\n");


pause();

