function gx = addpower_gaussian(x,mean,sigma,addpower)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
gx = (1 ./ (sqrt(sigma) * sqrt(2 * pi)) ) * exp( -(x - mean).^2 ./ (2 * sigma) + addpower);
end

