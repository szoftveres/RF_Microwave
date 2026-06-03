function nts = sweep2ts(sweeppoints)
    nts.points = [];
    for fp = 1:length(sweeppoints)
        nts.points(fp).f = sweeppoints(fp);
        nts.points(fp).S = zeros(2);
    end
end

    

