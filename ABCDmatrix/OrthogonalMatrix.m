function M = OrthogonalMatrix(Mo)
    Z = abcd2z(Mo)
    M = ParallelImpedanceMatrix(Z(1,1))
end
