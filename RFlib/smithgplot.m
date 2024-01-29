% script smithgplot

% [cp]
% optional: marker

function smithgplot(cp, mkr)
    Z = zeros(length(cp),1);
    for spn = 1:length(cp)
        Z(spn) = ((1 + cp(spn)) / (1 - cp(spn)));
    end
    if (nargin > 1)
        smithzplot(Z, mkr);
    else
        smithzplot(Z);
    end
end

