coarse_degrees = [0 30 60 90 120 150 180 210 240 270 300 330 360];
degrees = linspace(0,360,180);
theta = degrees * (pi / 180);

plotmin = 0;
plotmax = 60;
plotstep = 3;

figure;

antenna1 = [-41.8 -42.3 -43.7 -47.7 -53.7 -51.2 -50.2 -51.2 -53.7 -47.7 -43.7 -42.3 -41.8];
coarsegain1 = 95 + antenna1;
gain1 = interp1(coarse_degrees, coarsegain1, degrees);
h = polar(theta, gain1);
set (h, "linewidth", 3);
hold;

antenna2 = [-38.2 -42.2 -53.2 -75 -60 -62 -62 -62 -60 -75 -53.2 -42.2 -38.2];
coarsegain2 = 95 + antenna2;
gain2 = interp1(coarse_degrees, coarsegain2, degrees);
h = polar(theta, gain2);
set (h, "linewidth", 3);
hold;

set(gca, "rtick", plotmin:plotstep:plotmax);
title('Antenna gain pattern');
pause();

