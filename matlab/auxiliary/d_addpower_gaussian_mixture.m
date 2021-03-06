function [res] = d_addpower_gaussian_mixture(x,means,sigmas,weights,addpower)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
len_m = length(means);
len_s = length(sigmas);
len_w = length(weights);
res = zeros(size(x));
weights_sum = sum(weights);
if(weights_sum < 0.000001 )
    error("Invalid weights");
end
if ( (len_m ~= len_s) || (len_m ~= len_w) )
    error("Dimension discrepency among means, sigmas, or weights");
else
    for i = 1 : len_m
        res = res + ( - (x - means(i))/sigmas(i) ) .* addpower_gaussian(x, means(i), sigmas(i),addpower) * weights(i) / weights_sum;
    end
end
end

