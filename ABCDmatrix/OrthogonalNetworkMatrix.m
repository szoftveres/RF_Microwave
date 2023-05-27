function M = OrthogonalNetworkMatrix(Mo)
    Z = abcd2z(Mo)
    M = ShuntImpedanceMatrix(Z(1,1))
end
