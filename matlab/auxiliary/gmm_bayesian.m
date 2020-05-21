function [res] = gmm_bayesian(x_predict, y_x)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   compute gmm of p(x|y) = p(y|x)p(x_predict)/p(y)

[xp_means, xp_sigs, xp_weights, xp_com, xp_dim] = check_gmm_params(x_predict);
[yx_means, yx_sigs, yx_weights, yx_com, yx_dim] = check_gmm_params(y_x);

if xp_dim ~= yx_dim
    error('Dimension inconsistence in gmm_bayesian!');
end

%declaration
res = cell(size(x_predict));
res_com = xp_com * yx_com;
res_dim = xp_dim;
res{1} = zeros(res_com, res_dim);
res{2} = zeros(res_dim, res_dim, res_com);
res{3} = zeros(res_com,1);

res_mode = 0;
for xp_mode = 1:xp_com
    for yx_mode = 1:yx_com
        res_mode = res_mode + 1;    
        res{2}(:,:,res_mode) = inv( inv(xp_sigs(:,:, xp_mode)) + inv(yx_sigs(:,:, yx_mode)));
        dx = yx_means(yx_mode,:) - xp_means(xp_mode,:);
        res{1}(res_mode,:) = xp_means(xp_mode,:) +  ( dx...
            / (yx_sigs(:,:, yx_mode)) ) * res{2}(:,:,res_mode)' ;
        
        cov_sum = xp_sigs(:,:, xp_mode) + yx_sigs(:,:, yx_mode);
        abs_det = abs(det(sqrtm(cov_sum)));
        res{3}(res_mode) = xp_weights(xp_mode) * yx_weights(yx_mode) *...
            exp(-0.5 * (dx / ( cov_sum ) ) * dx' ) / abs_det;
    end
end
end

