function [gx] = gaussian_(x,mean,sigma)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
gx = (1 ./ (sqrt(sigma) * sqrt(2 * pi)) ) * exp( -(x - mean).^2 ./ (2 * sigma) );

end