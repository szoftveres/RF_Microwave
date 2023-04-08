
function M = z2abcd(Z)
    Zn = (Z(1,1) * Z(2,2)) - (Z(1,2) * Z(2,1))
    M = zeros(2)
    M(1,1) = Z(1,1) / Z(2,1)
    M(1,2) = Zn / Z(2,1)
    M(2,1) = 1 / Z(2,1)
    M(2,2) = Z(2,2) / Z(2,1)
end

