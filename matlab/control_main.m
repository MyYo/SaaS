function control_main 

    NumIter = 1;

    NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
    import uc480.*;
    import uc480.Info.*;
    import uc480.Defines.*;
    import uc480.Types.*;
    
    % set up translating stage
    device = init_stage();
%     if isa(device, 'handle') && isvalid(device)
%         fprintf("device is a handle object");
%     end
    
    camera = uc480.Camera;
    camera.Init(0);
    
%     cleanupObj = onCleanup(@cleanup);

    % set camera parameters
    camera.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
    camera.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
    camera.Trigger.Set(uc480.Defines.TriggerMode.Software);
    camera.Size.AOI.Set(0, 0, 1024, 1024);
    Gfactor = 0;
    camera.Gain.Hardware.Factor.SetMaster(Gfactor);
    camera.Timing.Exposure.Set(0.5);
    
    % allocate memory for camera capture
    [~, MemId] = camera.Memory.Allocate(true);
    [~, Width, Height, Bits, ~] = camera.Memory.Inquire(MemId);
    
    % allocate variables for data storage
    Data = zeros(Width, Height, NumIter);
    coeffs = zeros(5, NumIter);
    
    
    move_stage_at_vel(device, 1);
    freq = 2;
    r = robotics.Rate(freq); %in Hz; only accurate up to 100 Hz
    reset(r)
    for i = 1:NumIter
        execute_loop(i);
        waitfor(r);
        time = r.TotalElapsedTime;
        fprintf('Iteration: %d - Time Elapsed: %f\n',i,time);
    end
    device.Stop(7e4)
    cleanup();

    % plot 
    figure;
    himg = imshow(reshape(Data(:, :, 1), Width, Height));
    hold on;
    x = coeffs(1, 1);
    y = coeffs(2, 1);
    plot(x, y, 'r.','MarkerSize', 10);
    ang = 0:pi/64:2*pi;
    r = 2*coeffs(3, 1); % radius is 2 std devs

    circle_x = r*cos(ang) + x;
    circle_y = r*sin(ang) + y;
    plot(circle_x, circle_y, 'r');
    
    
    distances = coeffs(1, :);
    t = 1/freq:1/freq:NumIter*(1/freq);
    figure;
    plot(t, distances);
    

    function execute_loop(FrameCount)
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
        
        % store data
        Data(:, :, FrameCount) = Image;
        coeffs(:, FrameCount) = coeff;
        
        toc;
    end

    function cleanup()
        fprintf("cleaning up connected devices...\n");
        if isvalid(camera) && isvalid(device)
            camera.Exit;
            disconnect_stage(device);
        end
    end
end
