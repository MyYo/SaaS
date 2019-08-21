function control_loop()
    tic;
    fprintf('Executing loop...\n');
    
    % TODO: get image
    [~, MemId] = camera.Memory.Allocate(true);
    [~, Width, Height, Bits, ~] = camera.Memory.Inquire(MemId);
    camera.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
    [~, tmp] = camera.Memory.CopyToArray(MemId);
    Data = reshape(uint8(tmp), [Bits/8, Width, Height]);
    Data = Data(1:3, 1:Width, 1:Height);
    Data = permute(Data, [3,2,1]);
    himg = imshow(Data);
    
    % find Gaussian center
    coeffs = fmin_gaussian(Data, 1);
    y = coeffs(1);
    hold on;
    plot(coeffs(1), coeffs(2), 'r.','MarkerSize', 10);
    ang = 0:pi/64:2*pi;
    r = 2*coeffs(3); % 2 std devs
    circle_x = r*cos(ang) + coeffs(1);
    circle_y = r*sin(ang) + coeffs(2);
    plot(circle_x, circle_y, 'r');
    
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