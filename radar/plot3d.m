pkg load signal;


load("plotarray.txt");


plotmin = min(min(plotarray));
plotmax = max(max(plotarray));
plotampl = (plotmax - plotmin);

plotmean = mean(mean(plotarray));


figure;
%colormap ("gray");
h = pcolor(plotarray);
set(h, 'EdgeColor', 'none');
caxis([(plotmin + (plotampl*0.01))      (plotmax )]);


printf("\nDone.\n");


pause();

