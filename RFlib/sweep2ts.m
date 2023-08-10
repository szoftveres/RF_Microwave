function nts = sweep2ts(sweeppoints, Z0)
    nts.points = []
    for fp = 1:length(sweeppoints)
        nts.points(fp).f = sweeppoints(fp)
        nts.points(fp).Z = Z0
        nts.ABCD = zeros(2)
    end
end

    

