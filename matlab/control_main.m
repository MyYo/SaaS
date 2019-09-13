function control_main 

    NumOfFrames = 10;

    NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
    import uc480.*;
    import uc480.Info.*;
    import uc480.Defines.*;
    import uc480.Types.*;
    
    camera = uc480.Camera;
    camera.Init(0);

    %Setting the values you want for different options can be done by typing
    %the class name and using the appropriate Set commands for the different
    %options, based on those available for the camera from the .Net manual
    camera.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
    camera.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
    camera.Trigger.Set(uc480.Defines.TriggerMode.Software);
    camera.Size.AOI.Set(0, 0, 1024, 1024);
    
    Gfactor = 0;
    camera.Gain.Hardware.Factor.SetMaster(Gfactor);
    camera.Timing.Exposure.Set(0.3);
    
    % allocate memory for image
    [~, MemId] = camera.Memory.Allocate(true);
    [~, Width, Height, Bits, ~] = camera.Memory.Inquire(MemId);
    
    % variables
    Data = zeros(Width, Height, NumOfFrames);
    coeffs = zeros(5, NumOfFrames);
    FrameCount = 1;
    
    t = timer;
    t.ExecutionMode = 'fixedRate';
    t.Period = 1;
    t.TasksToExecute = NumOfFrames;
    t.TimerFcn = @get_image;
    start(t);
    fprintf("FrameCount %d", FrameCount);
    
    if FrameCount > NumOfFrames
        camera.Exit;
        fprintf("finished.");

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
    end

    function get_image(~,~)
        tic;    
        camera.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
        [~, tmp] = camera.Memory.CopyToArray(MemId);
        Image = reshape(uint8(tmp), [Bits/8, Width, Height]);
        Image = Image(:, 1:Width, 1:Height);
        Image = permute(Image, [3,2,1]);
        Image = im2double(Image);
        Data(:, :, FrameCount) = Image;
        
        % find Gaussian center
        coeff = fmin_gaussian(Image, 4);
        coeffs(:, FrameCount) = coeff;
        toc;
        FrameCount = FrameCount + 1;
    end
end
