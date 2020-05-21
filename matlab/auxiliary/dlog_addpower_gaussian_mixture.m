function [res] = dlog_addpower_gaussian_mixture(x,means,sigmas,weights,addpower)
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
den = sum(addpower_gaussian_mixture(x,means,sigmas,weights,addpower));
if isnan(den) 
    error('den is nan');
elseif isinf(den)
    error('den is inf');
else
    num = sum(d_addpower_gaussian_mixture(x,means,sigmas,weights,addpower));
    res =  num / den;
end
end

