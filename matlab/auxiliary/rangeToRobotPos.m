function res = rangeToRobotPos(range,reflectors, unbounded)
%RANGETOROBOTPOS Summary of this function goes here
%   Detailed explanation goes here
res = [];
len = length(reflectors);

if unbounded
    res = [res, reflectors(1) - range];
end

far_left_pos = reflectors(1) + range;
if far_left_pos <= 0.5 * (reflectors(1) + reflectors(2))
    res = [res, far_left_pos];
end

for i = 2 : len-1
    left_pos = reflectors(i) - range;
    if left_pos >= 0.5 * (reflectors(i) + reflectors(i-1))
        res = [res, left_pos];
    end
    right_pos = reflectors(i) + range;    
    if right_pos <= 0.5 * (reflectors(i) + reflectors(i+1))
        res = [res, right_pos];    
    end
end

far_right_pos = reflectors(end) - range;
if far_right_pos >= 0.5 * (reflectors(end) + reflectors(end-1))
    res = [res, far_right_pos];
end

if unbounded
    res = [res, reflectors(end) + range];
end

end