function control_loop(Data)
    tic;
    fprintf('Executing loop...\n');
    
   
%     % find Gaussian center
%     coeffs = fmin_gaussian(Data, 1);
%     y = coeffs(1);
%     hold on;
%     plot(coeffs(1), coeffs(2), 'r.','MarkerSize', 10);
%     ang = 0:pi/64:2*pi;
%     r = 2*coeffs(3); % 2 std devs
%     circle_x = r*cos(ang) + coeffs(1);
%     circle_y = r*sin(ang) + coeffs(2);
%     plot(circle_x, circle_y, 'r');
    
%     % control system
%     kp = -1;
%     kd = -1;
%     ki = -1;
%     
%     persistent error_sum
%     persistent last_error
%     if isempty(error_sum)
%         error_sum = 0;
%     end
%     if isempty(last_error)
%         last_error = 0;
%     end
%     
%     error = y_des - y;
%     error_sum = error_sum + error;
%     u_dot = kp*error + kd*(error - last_error) + ki*error_sum;
%     
%     if u_dot > v_max
%         u_dot = v_max; % cap @ max velocity
%         error_sum = error_sum - error; % anti-windup
%     elseif u_dot < -v_max
%         u_dot = -v_max;
%         error_sum = error_sum - error;
%     end
    
    % TODO: send u_dot to motor controller
    toc;
end