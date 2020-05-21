function [means, sigs, weights, components, dim] = check_gmm_params(gmm_params)
%   Expect xk_params is a cell array in which {1} is a k-by-m array storing
%   means, {2} is an m-by-m-by-k array representing covariance matrix, {3}
%   is a vector of length k. k is the number of components and m is the
%   number of variables.
len_cell = length(gmm_params);
if(len_cell ~= 3)
    error(['Input gmm cell only has ',num2str(len_cell),' elements']);
end
means = gmm_params{1};
sigs = gmm_params{2};
weights = gmm_params{3};
[components, dim] = size(means);

size_sigs = size(sigs);
len_weights = length(weights);
if components > 1
if(size_sigs(1) == dim && size_sigs(2) == dim && size_sigs(3) == components ...
        && len_weights == components)
else
    error('Something goes wrong in gmm params sizes');
end
end

end

