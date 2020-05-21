function [outputArg1,outputArg2] = ray_cast(rbt_pos,obstacles)
%RAY_CAST Summary of this function goes here
%   Detailed explanation goes here
[min_ray, obstacle_id] = min( abs(obstacles - rbt_pos));
outputArg1 = min_ray;
outputArg2 = obstacle_id;
end

