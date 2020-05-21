function res = gmm_prior_odo_obs(prior_params, odo_params, obs_params)
%GMM_PRIOR_ODO_OBS Summary of this function goes here
%   Detailed explanation goes here
% compute gmm of p(xk1|y) = p(y|xk1) integral( p(xk1|xk)p(xk) dxk )/p(y)
% we could directly compute means, sigmas, and weights of the resulting gmm
% in a combinatory way.
% 
xk1_predict = gmm_margin(prior_params, odo_params);
res = gmm_bayesian(xk1_predict, obs_params);
end
