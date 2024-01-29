function nts = sweep2ts(sweeppoints)
    nts.points = [];
    for fp = 1:length(sweeppoints)
        nts.points(fp).f = sweeppoints(fp);
        nts.ABCD = zeros(2);
    end
end

    

