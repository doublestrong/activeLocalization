function [res] = d_gaussian_mixture_(x,means,sigmas,weights)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
len_m = length(means);
res = zeros(size(x));
weights_sum = sum(weights);

for i = 1 : len_m
    res = res + ( - (x - means(i))/sigmas(i) ) .* gaussian_(x, means(i), sigmas(i)) * weights(i) / weights_sum;
end

end

