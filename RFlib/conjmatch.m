%
% This function calculates the complex impedance that the
% active device wants to see on its port
%

function g = conjmatch(S_thisside, S_otherside, S)

    B = 1 + (abs(S_thisside)^2) - (abs(S_otherside)^2) - (abs(determinant(S))^2);
    C = S_thisside - (determinant(S) * conj(S_otherside));

    g = (
        B - sqrt((B^2) - (4 * (abs(C)^2)))
    ) / (
        2 * C
    );
end
