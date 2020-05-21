function [x,y] = hist2plot(samples,bin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
[N,edges] = histcounts(samples,10, 'Normalization','pdf');
else
[N,edges] = histcounts(samples,bin, 'Normalization','pdf'); 
end

edges = edges(2:end) - (edges(2)-edges(1))/2;
x = edges;
y = N;
end