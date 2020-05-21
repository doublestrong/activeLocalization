function [res] = dlog_gmm(x,means,sigmas,weights)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   compute d(log p) where p is a Gaussian mixture function
%   "means" "sigmas" "weights" are parameters of all the modes.
%   for examle, p(x) = sum( weights(i) * N(x,means(i),sigmas(i)) )
%   Ex1: in the case of odometry, you may want to input "means" by x_prior +
%   dynamics_mean and sigmas will be something like dynamics_sigma * ones(size(x_prior));
%   and weights will be somethig like ones(size(x_prior))
%   Ex2: in the case of GMM observation model, means, sigmas, weights are
%   from the model.
den = gaussian_mixture_(x,means,sigmas,weights);
if den < 1e-300
% option one: get the furthest one as the gradient
    dis = abs(x - means);
    [mindis, i] = min(dis);
    res = dlog_gaussian(x,means(i),sigmas(i));
% option two: get the 
    
else
    num = d_gaussian_mixture_(x,means,sigmas,weights);
    res =  num ./ den;
end
end

