function y = position_controller(y, y_des, y_max, y_min)
    persistent error_sum
    kp = -1; 
    ki = -1;
    
    if isempty(error_sum)
        error_sum = 0;
    end
    error_sum = error_sum + (y_des-y);
    y = kp * (y_des-y) + ki * error_sum;
    
    if y > y_max
        % cap max y
        y = y_max;
        % anti-windup
        error_sum = error_sum - (y_des-y);
    elseif y < y_min
        y = y_min;
        error_sum = error_sum - (y_des-y);
    end
end
