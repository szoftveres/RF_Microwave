% 3-term error correction

function S = p1cal(S, So, Ss, Sl, Go, Gs, Gl)
    % Error coefficients
    C = [Go 1 (Go * So);
         Gs 1 (Gs * Ss);
         Gl 1 (Gl * Sl)];

    V = [So;
         Ss;
         Sl];

    E = inv(C' * C) * C' * V;
    e00 = E(2); % Directivity error
    e11 = E(3); % Source match error
    e10e01 = E(1) + (E(2) * E(3)); % Reflection tracking error
    detm = (e00 * e11) - e10e01;

    S = (S - e00) / ((S * e11) - detm);
end


%    % Error network S-parameter matrix
%    Se = zeros(2);
%    Se(1,1) = e00;
%    Se(1,2) = sqrt(e10e01);
%    Se(2,1) = sqrt(e10e01);
%    Se(2,2) = e11;

