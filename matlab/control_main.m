function control_main 
    close all; clear; clc;

    NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
    import uc480.*;
    import uc480.Info.*;
    import uc480.Defines.*;
    import uc480.Types.*;
        
    % define paramters
    NumIter = 100;
    freq = 3; % in Hz, only accurate up to 100 Hz
    r = robotics.Rate(freq);
    
    % define desired output
    beam_des = 2.976; % mm, center of screen
    desired_positions = ones(NumIter)*beam_des;
    
    % allocate variables for data storage
    gauss_coeffs = zeros(5, NumIter);
    stage_positions = zeros(NumIter);
    requested_velocities = zeros(NumIter);
    dT = 1/freq;
    t = 0:dT:(NumIter-1)*dT;
    
    try
        % set up translating stage
        fiber_stage = init_stage('27254054', 1); % stage and camera are both handle objects
%         lens_stage = init_stage('27254043', 0);
%         camera_stage = init_stage('27505183', 16);

        camera = uc480.Camera;
        camera.Init(0);
    
        % set camera parameters
        camera.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
        camera.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
        camera.Trigger.Set(uc480.Defines.TriggerMode.Software);
        camera.Size.AOI.Set(0, 0, 1024, 1024);
        Gfactor = 0;
        camera.Gain.Hardware.Factor.SetMaster(Gfactor);
        camera.Timing.Exposure.Set(2);

        % allocate memory for camera capture
        [~, MemId] = camera.Memory.Allocate(true);
        [~, Width, Height, Bits, ~] = camera.Memory.Inquire(MemId);
        Data = zeros(Width, Height, NumIter);


        reset(r)
%         move_stage_at_vel(camera_stage, 0.1);
        for i = 1:NumIter
            execute_loop(i);
            waitfor(r);
            % time = r.TotalElapsedTime;
            % fprintf('Iteration: %d - Time Elapsed: %f\n',i,time);
        end
%         camera_stage.Stop(7e4);
        fiber_stage.Stop(7e4);
%         lens_stage.Stop(7e4);
        
    catch e
        fprintf('Error encountered... ');
        cleanup();
        rethrow(e);
    end
    cleanup();

    % plot 
%     imwrite(Data(:, :, 1), 'realtime.bmp');
%     for i = 1:NumIter
%         figure;
%         imshow(reshape(Data(:, :, NumIter), Width, Height));
%         hold on;
%         x = gauss_coeffs(1, NumIter);
%         y = gauss_coeffs(2, NumIter);
%         plot(x, y, 'r.','MarkerSize', 10);
%         ang = 0:pi/64:2*pi;
%         r = 2*gauss_coeffs(3, NumIter); % radius is 2 std devs
% 
%         circle_x = r*cos(ang) + x;
%         circle_y = r*sin(ang) + y;
%         plot(circle_x, circle_y, 'r');
%     end
    
    beam_centers = gauss_coeffs(1, :)*0.00465;
    % p = polyfit(t, beam_centers, 1);
    % best_fit_line = p(1)*t + p(2);
    % fprintf('Velocity of beam is: %f\n', p(1));
    
    % calculate actual stage velocity
    stage_velocities = zeros(NumIter);
    for i = 2:NumIter
        stage_velocities(i) = (stage_positions(i)-stage_positions(i-1))/dT;
    end
    
    
    figure;
    subplot(4, 1, 1);
    hold on;
    plot(t, beam_centers);
    plot(t, desired_positions);
    legend('actual', 'desired');
    ylabel('Beam Pos [mm]');
    
    subplot(4, 1, 2);
    plot(t, stage_positions);
    ylabel('Stage Pos [mm]');
    
    subplot(4, 1, 3);
    plot(t, requested_velocities);
    ylabel('Requested Stage Velocity [mm/s]');
    
    subplot(4, 1, 4);
    plot(t, stage_velocities);
    ylabel('Actual Stage Velocity [mm/s]');
    xlabel('Time [s]');

    function execute_loop(IterCount)
        tic;  
        
        % capture image
        camera.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
        [~, tmp] = camera.Memory.CopyToArray(MemId);
        Image = reshape(uint8(tmp), [Bits/8, Width, Height]);
        Image = Image(:, 1:Width, 1:Height);
        Image = permute(Image, [3,2,1]);
        Image = im2double(Image);
        
        % find Gaussian center
        coeff = fmin_gaussian(Image, 4);
        beam_pos = coeff(1)*0.00465;
        
        % store beam data
        Data(:, :, IterCount) = Image;
        gauss_coeffs(:, IterCount) = coeff;
        
        % record stage position
        stage_pos = System.Decimal.ToDouble(fiber_stage.Position);
        fprintf('The motor position is: %d \n',stage_pos);
        stage_positions(IterCount) = stage_pos;
        
        vel = velocity_controller(beam_pos, beam_des, 2.4);
        move_stage_at_vel(fiber_stage, vel);
%         move_stage_at_vel(lens_stage, vel);
        requested_velocities(IterCount) = vel;
        toc;
    end

    function cleanup()
        fprintf('Cleaning up.\n');
        if exist('camera', 'var')
            camera.Exit;
        end
        if exist('fiber_stage', 'var')
            disconnect_stage(fiber_stage);
        end
        if exist('lens_stage', 'var')
            disconnect_stage(lens_stage);
        end
        if exist('camera_stage', 'var')
            disconnect_stage(camera_stage);
        end
        
        % clear persistent variables on auxillary functions
        clear move_stage_at_vel;
        clear velocity_controller;
        clear fmin_gaussian;
    end

end
