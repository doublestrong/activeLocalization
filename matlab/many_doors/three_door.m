clear all;
close all;
%range of the environment
door_max = 1500;
door_min = -500;
unbounded = 1;

%plotting setting
plot_flag = 1;

%sampling setting
pos_sample_num = 100;
obs_sample_num = 50;
blv_sample_num = 100;
entropy_sample_num = pos_sample_num * obs_sample_num;
weight_pruned_comp = 1e-8;

%doors
doors = [door_min,0, door_max];

%models
obs_var = 2500;
odo_var_per_meter = 100;

%robot_initial position (ground truth)
rbt_gt = 0;

%robot ray casting function and invert to robot positions
[cloest_ray, reflector_id] = ray_cast(rbt_gt, doors);
robot_pos_means = rangeToRobotPos(cloest_ray, doors, unbounded);
range_data = [cloest_ray];

%position belief after the first observation
rbt_pos_blv = gmdistribution(robot_pos_means', obs_var);
rbt_pos_samples = random(rbt_pos_blv, blv_sample_num);
rbot_blv_entropy = -mean(log(pdf(rbt_pos_blv,rbt_pos_samples)));

%plot the belief after the first observation
% if plot_flag
% figure(1)
% plot_x = [door_min-max(range_data)-500:door_max+max(range_data)+500]';
% plot(plot_x, pdf(rbt_pos_blv,plot_x));
% hold on;
% end

num_hypothesis = length(robot_pos_means);

robot_pos_means = robot_pos_means';
for i = 1 : num_hypothesis
    cov_prior(:,:,i) = [obs_var];
end
weights = ones(size(robot_pos_means));
prior_params = {robot_pos_means, cov_prior, weights};

reward =  -9999999;
action = -999999;
entropy_change = 999999;
max_steps = 10;
cur_step = 0;

belief_gm_sets = cell(max_steps+1,1);
belief_gm_sets{1} = rbt_pos_blv;
%all candidate actions and their rewards (information gain)
action_sets = cell(max_steps,1);
best_actions = zeros(max_steps,1);
robot_trajectory = zeros(max_steps+1,1);
robot_trajectory(1) = rbt_gt;
rbt_entropy_list = zeros(max_steps+1,1);
rbt_entropy_list(1) = rbot_blv_entropy;
while entropy_change > 0.01 && cur_step < max_steps
    cur_step = cur_step + 1
    max_move = 200;%doors(end) - min(robot_pos_means);
    min_move = -200;%doors(1) - max(robot_pos_means);
    candidate_moves = min_move: 100 : max_move;
    
    %candidate actions at current step
    cur_action_set = zeros(length(candidate_moves),2);
    for move_idx = 1 : length(candidate_moves)
        tmp_move = candidate_moves(move_idx)
        
        entropy_over_obs = zeros(entropy_sample_num,1);
        entropy_idx = 0;
%         for debugging
%         all_obs = zeros(entropy_sample_num,1);
        
        %compute gmm of predicted move
        cov_d(:,:,1) = [odo_var_per_meter * (abs(tmp_move)/100)];
        odo_params = {[tmp_move], cov_d, [1]};
        pred_pos_params = gmm_prior_odo(prior_params, odo_params);
        pred_pos_gm = gmdistribution(pred_pos_params{1}, ...
            pred_pos_params{2}, pred_pos_params{3});
        pred_pos_samples = random(pred_pos_gm, pos_sample_num);
        for pos_idx = 1 : pos_sample_num
            closest_ray = ray_cast(pred_pos_samples(pos_idx), doors);
            %as ray is distributed on a Gaussian which have no probability
            %mass on the negative part of real line
            obs_samples = zeros(obs_sample_num,1);
            cur_obs_sample_num = 0;
            while cur_obs_sample_num < obs_sample_num
                cur_obs_sample = normrnd(closest_ray, sqrt(obs_var));
                if cur_obs_sample >= 0
                    cur_obs_sample_num = 1 + cur_obs_sample_num;
                    obs_samples(cur_obs_sample_num) = cur_obs_sample;

                    cur_pos_means = rangeToRobotPos(cur_obs_sample, ...
                        doors, unbounded);
                    cur_pos_means = cur_pos_means';
                    for mean_idx = 1 : length(cur_pos_means)
                        cov_obs(:,:,mean_idx) = [obs_var];
                    end
                    weights = ones(size(cur_pos_means));
                    obs_params = {cur_pos_means, cov_obs, weights};                    
                    cur_pos_blv_params = gmm_prior_odo_obs(prior_params,...
                        odo_params, obs_params);
                    clear cov_obs;
                    sgnf_comp = cur_pos_blv_params{3}/sum(cur_pos_blv_params{3}) > weight_pruned_comp;
                    cur_pos_blv_params{1} = cur_pos_blv_params{1}(sgnf_comp);
                    cur_pos_blv_params{2} = cur_pos_blv_params{2}(:,:,sgnf_comp);
                    cur_pos_blv_params{3} = cur_pos_blv_params{3}(sgnf_comp);
                    
                    %abandon this sample of observation
                    if isempty(cur_pos_blv_params{3})
                        cur_obs_sample_num = cur_obs_sample_num - 1;
                        continue;
                    end
                    
                    cur_pos_blv_gm = gmdistribution(...
                        cur_pos_blv_params{1}, cur_pos_blv_params{2},...
                        cur_pos_blv_params{3});
                    cur_pos_blv_samples = random(cur_pos_blv_gm,...
                        blv_sample_num);
                    entropy_idx = entropy_idx + 1;
                    entropy_over_obs(entropy_idx) = -mean(log(pdf(cur_pos_blv_gm,cur_pos_blv_samples)));
%                     all_obs(entropy_idx) = cur_obs_sample;
                end
            end
            %the measurement model is modelled as half gaussian
        end
        tmp_reward = -mean(entropy_over_obs)
        cur_action_set(move_idx,:)=[tmp_move,tmp_reward];

        if tmp_reward > reward
            reward  = tmp_reward;
            action = tmp_move;
        end
    end
    
    %executing the best action
    action
    rbt_gt = rbt_gt + action
    [cloest_ray, reflector_id] = ray_cast(rbt_gt, doors);
%     raw data of range measurements
    range_data = [range_data, cloest_ray];
    cur_pos_means = rangeToRobotPos(cloest_ray, ...
        doors, unbounded);
    cur_pos_means = cur_pos_means';
    for mean_idx = 1 : length(cur_pos_means)
        cov_obs(:,:,mean_idx) = [obs_var];
    end
    weights = ones(size(cur_pos_means));
    obs_params = {cur_pos_means, cov_obs, weights};   
    cov_d(:,:,1) = [odo_var_per_meter * sqrt(abs(action)/100)];
    odo_params = {[action], cov_d, [1]};
    prior_params = gmm_prior_odo_obs(prior_params,...
        odo_params, obs_params);
    clear cov_obs;
    sgnf_comp = prior_params{3}/sum(prior_params{3}) > weight_pruned_comp;
    prior_params{1} = prior_params{1}(sgnf_comp);
    prior_params{2} = prior_params{2}(:,:,sgnf_comp);
    prior_params{3} = prior_params{3}(sgnf_comp);
    rbt_pos_blv = gmdistribution(prior_params{1},prior_params{2},prior_params{3});
    
    %storing results
    action_sets{cur_step} = cur_action_set;
    belief_gm_sets{1+cur_step} = rbt_pos_blv;    
    best_actions(cur_step) = action;
    robot_trajectory(cur_step+1) = rbt_gt;
    %update entropy

    rbt_pos_samples = random(rbt_pos_blv, blv_sample_num);
    rbot_blv_entropy = -mean(log(pdf(rbt_pos_blv,rbt_pos_samples)));
    rbt_entropy_list(cur_step+1) = rbot_blv_entropy;
    
    entropy_change = abs(rbt_entropy_list(cur_step+1) ...
        - rbt_entropy_list(cur_step));


end

if plot_flag
    figure(1)
    %plot trajectory, entroy
    subplot(1,3,1)
    plot(robot_trajectory(1:cur_step+1));
    xlabel('Action step');
    ylabel('Robot position (cm)');
    subplot(1,3,2)
    plot(rbt_entropy_list(1:cur_step+1));
    xlabel('Action step');
    ylabel('Entropy of belief (-)');
    subplot(1,3,3)
    plot_x = [door_min-max(range_data)-500:door_max+max(range_data)+500]';
    for i = 1 : cur_step+1
        plot(plot_x, pdf(belief_gm_sets{i},plot_x)); 
        xlabel('Robot position (cm)');
        ylabel('Belief');
        time_text = text(0,0.025,['step' num2str(i-1)]);
        ylim([0, 0.03]);
        pause(1);
        delete(time_text);
    end    
end