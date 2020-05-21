function res = range_rej_sampling(ray,sig, num)
% samples are 
%
normalization = 1 - normcdf(0 , ray, sig);
multiplier = (1/normalization) + 0.01;



end