clear;
clc;
close all;
%  
% % set up camera
% NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
% import uc480.*;
% import uc480.Info.*;
% import uc480.Defines.*;
% import uc480.Types.*;
% camera = uc480.Camera;
% camera.Init(0);
%  
% % getting information from the classes, first create an array for each of
% % the values that make up the data structure with a temp as the first array 
% % value, then include an array member for each value of interest (all others
% % can be ~ if not used) making sure to name it something identifiable. Then 
% % call the method of the class like below
% [~, PosX, PosY, PixelWidth, PixelHeight] = GetOriginal(camera.Size.AOI);
% [~, MasterGain] = GetMaster(camera.Gain.Hardware.Factor);
% [~, CurrentFPS] = GetCurrentFps(camera.Timing.Framerate);
% [~, FRMin, FRMax, FRInc] = GetFrameRateRange(camera.Timing.Framerate);
% [~, ExpMin, ExpMax, ExpInc] = GetRange(camera.Timing.Exposure);
%  
% % Setting the values you want for different options can be done by typing
% % the class name and using the appropriate Set commands for the different
% % options, based on those available for the camera from the .Net manual
% camera.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
% camera.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);
% camera.Trigger.Set(uc480.Defines.TriggerMode.Software);
% camera.Size.AOI.Set(0, 0, 512, 512);
% Gfactor = 0; % master gain
% camera.Gain.Hardware.Factor.SetMaster(Gfactor);
% camera.Timing.Exposure.Set(0.3);
 
t = timer('ExecutionMode','fixedRate',...
    'Period', 3,...
    'TimerFcn', 'control_loop()',...
    'TasksToExecute', 20);
start(t);

% camera.Exit;


