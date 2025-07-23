
pkg load signal;

arraydim_x = 1024
arraydim_y = 64


structure_start = 384

scenery = zeros(arraydim_y, arraydim_x);

for x = structure_start:arraydim_x-structure_start
    scenery(32, x) = 2;
end

for x = structure_start-64:structure_start
    scenery(48, x) = 2;
end
for x = arraydim_x-structure_start:arraydim_x-structure_start+64
    scenery(48, x) = 2;
end

for y = 32:48
    scenery(y, structure_start) = 2;
    scenery(y, arraydim_x-structure_start) = 2;
    scenery(y, 512-y*4) = 2;
end

scenery(39, arraydim_x/2) = 2;
scenery(40, arraydim_x/2) = 2;
scenery(41, arraydim_x/2) = 2;
scenery(39, (arraydim_x/2)+1) = 2;
scenery(40, (arraydim_x/2)+1) = 2;
scenery(41, (arraydim_x/2)+1) = 2;


% ==============================


y_dist_m = 5;                                   % 5m per pixel
x_speed_mps = 15.64;                            % 35mph
x_repetition_rate = 5 ;                         % radar 5Hz -> need to decimate from 100 to 5
x_dist_m = x_speed_mps / x_repetition_rate      % distance between two consecutive sweeps (locations)
xy_ratio = x_dist_m / y_dist_m



xy_ratio = 0.5

scan_locations = 256:8:arraydim_x-256;

length(scan_locations)

echoarray = ones(arraydim_y, length(scan_locations));


window = gausswin(arraydim_y * 2) .* gausswin(arraydim_y * 2);



nloc = 1;
for loc = scan_locations
    loc
    for dist = 1:arraydim_y-1  % this is in 5m / pixel
        for x = round(loc-(dist/xy_ratio)-1) : round(loc+(dist/xy_ratio)+1)    % this is in 0.16m / pixel
            if ((x < 1) || (x > arraydim_x))
                continue;
            end
            _x_ = abs(x-loc) * xy_ratio;
            for y = 1 : dist+1
                if round(sqrt(_x_^2 + y^2)) == dist
                    echoarray(dist, nloc) += (scenery(y, x) * window(round(_x_ + arraydim_y)));
%                    scenery(y, x) = 10 * window(round(abs(x-loc) * xy_ratio) + arraydim_y);
                endif
            end
        end
    end
    nloc += 1;
end

figure;
h = pcolor(scenery);
set(h, 'EdgeColor', 'none');


plotarray = ones(arraydim_y, arraydim_x);

nloc = 1;
for loc = scan_locations
    loc
    for dist = 1:arraydim_y-1  % this is in 5m / pixel
        for x = round(loc-(dist/xy_ratio)-1) : round(loc+(dist/xy_ratio)+1)    % this is in 0.16m / pixel
            if ((x < 1) || (x > arraydim_x))
                continue;
            end
            _x_ = (x-loc) * xy_ratio;
            for y = 1 : dist+1
                if round(sqrt(_x_^2 + y^2)) == dist
                    plotarray(y,x) *= echoarray(dist, nloc);
                endif
            end
        end
    end
    nloc += 1;
end


plotarray = log10(plotarray);


save sar.txt plotarray



plotmin = min(min(plotarray));
plotmax = max(max(plotarray));
plotampl = (plotmax - plotmin);

plotmean = mean(mean(plotarray));


figure;
%colormap ("gray");
h = pcolor(plotarray);
set(h, 'EdgeColor', 'none');
caxis([(plotmin + (plotampl*0.33))      (plotmax )]);


printf("\nDone.\n");


pause();

