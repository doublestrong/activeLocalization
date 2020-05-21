door_sig = 0.2;
door_means = [-3; 0; 4];
weights = [1; 1; 1];
cov_p(:,:,1) = [door_sig];
cov_p(:,:,2) = [door_sig];
cov_p(:,:,3) = [door_sig];
obs_params = {door_means, cov_p, weights};
prior_params = obs_params;
analytic_obs = gmdistribution(obs_params{1}, obs_params{2},obs_params{3});
for i = 1:10
analytic_p = gmm_bayesian(prior_params, obs_params);
analytic_gmm = gmdistribution(analytic_p{1}, analytic_p{2},analytic_p{3});
analytic_prior = gmdistribution(prior_params{1}, prior_params{2},prior_params{3});
prior_params = analytic_p;
x = [-6:0.02:8]';
plot(x, pdf(analytic_gmm,x));hold on;
plot(x, pdf(analytic_obs,x));

plot(x, pdf(analytic_prior, x));
legend('posterior','obs','prior');
hold off;
end