function [res] = gmm_margin(xk_params,xk1xk_params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   marginalize p(xk1 | xk)p(xk) over xk in a parametric way
%   Expect xk_params is a cell array in which {1} is a k-by-m array storing
%   means, {2} is an m-by-m-by-k array representing covariance matrix, {3}
%   is a vector of length k. k is the number of components and m is the
%   number of variables.

[xk_means, xk_sigs, xk_weights, xk_com, xk_dim] = check_gmm_params(xk_params);
[xk1xk_means, xk1xk_sigs, xk1xk_weights, xk1xk_com, xk1xk_dim] = check_gmm_params(xk1xk_params);

if xk_dim ~= xk1xk_dim
    error('Dimension inconsistence in gmm_margin!');
end

%declaration
res = cell(size(xk_params));
res_com = xk_com * xk1xk_com;
res_dim = xk_dim;
res{1} = zeros(res_com, res_dim);
res{2} = zeros(res_dim, res_dim, res_com);
res{3} = zeros(res_com,1);

res_mode = 0;
for xk_mode = 1:xk_com
    for xk1xk_mode = 1:xk1xk_com
        res_mode = res_mode + 1;
        res{1}(res_mode,:) = xk_means(xk_mode,:) + xk1xk_means(xk1xk_mode,:);
        res{2}(:,:,res_mode) = xk_sigs(:,:, xk_mode) + xk1xk_sigs(:,:, xk1xk_mode) ;
        res{3}(res_mode) = xk_weights(xk_mode) * xk1xk_weights(xk1xk_mode);
    end
end

end

