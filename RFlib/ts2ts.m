function nts = ts2ts(ts)
    nts.points = [];
    for fp = 1:length(ts.points)
        nts.points(fp).f = ts.points(fp).f;
        nts.ABCD = zeros(2);
    end
end

    

