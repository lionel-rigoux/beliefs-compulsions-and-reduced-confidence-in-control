function c = colorsPOMDP(idx)

if nargin == 0
    idx = 1:3;
end

c(1,:) = [125 211 034]/255;
c(2,:) = [208 003 027]/255;
c(3,:) = [074 144 226]/255;

c = c(idx,:);