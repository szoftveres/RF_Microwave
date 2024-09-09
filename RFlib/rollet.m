function r = rollet(S)
    r = (
            1-(abs(S(1,1))^2)-(abs(S(2,2))^2)+(abs(determinant(S))^2)
        ) / (
            2 * (abs(S(1,2) * S(2,1)))
        );
end
