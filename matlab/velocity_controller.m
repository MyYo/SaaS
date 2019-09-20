function y_dot = velocity_controller(y, y_des, v_max)
    kp = 10;
    kd = 1;
    ki = 5;
    
    persistent error_sum
    persistent last_error
    if isempty(error_sum)
        error_sum = 0;
    end
    if isempty(last_error)
        last_error = 0;
    end
    
    error = y_des - y;
    error_sum = error_sum + error;
    y_dot = kp*error + kd*(error - last_error) + ki*error_sum;
    
    if y_dot > v_max
        y_dot = v_max; % cap @ max velocity
        error_sum = error_sum - error; % anti-windup
    elseif y_dot < -v_max
        y_dot = -v_max;
        error_sum = error_sum - error;
    end
end