function [res] = dlog_gaussian(x,mean,sigma)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
res = -(x - mean) / sigma^2;
end

