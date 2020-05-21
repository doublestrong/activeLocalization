function [res] = log_gmm_aprox(x,means,sigmas,weights)
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
len_m = length(means);
len_sample = length(x);
weights_sum = sum(weights);
weight_gaussians = zeros(len_m,1);
res = zeros(size(x));
for i = 1:len_sample
    for j = 1 : len_m
        weight_gaussians(j) = gaussian_(x(i), means(j), sigmas(j)) * weights(j) / weights_sum;
    end
    tmpres = log(sum(weight_gaussians));
    if isinf(tmpres)
        [val, idx] = min( abs(x(i) - means)./sigmas);
        tmpres = -log(sqrt(2*pi)/sigmas(idx)) - (x(i) - means(idx))^2/2/sigmas(idx)^2;
    end
    res(i) = tmpres;
end
end

