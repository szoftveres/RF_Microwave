function sweeppoints = ts2sweep(ts)
    sweeppoints = [];
    for fp = 1:length(ts.points)
        sweeppoints = [sweeppoints; ts.points(fp).f];
    end
end

    

