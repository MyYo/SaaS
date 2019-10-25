function device = init_stage(serial_num, init_pos)
%% INITIALIZE & CONNECT DEVICES
% Execute the following sections sequentially and DO NOT call .StopPolling() 
% or .Disconnect() until you are finished executing commands like .MoveTo()
% or .MoveContinuousAtVelocity().
%
% ***IMPORTANTLY: if you refrain from executing bad code between 
% stage_init() and stage_disco(), you should never need to physically 
% reconnect the device via USB-replug or reboot.***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load assemblies
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*

% Initialize Device List
DeviceManagerCLI.BuildDeviceList();
DeviceManagerCLI.GetDeviceListSize();

% ***Should change the serial number(s) below to those being used***
timeout_val = 7e4; % Increased from 6e4 to facilitate full range of motion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set-up and connect to device(s), then configure
device = KCubeDCServo.CreateKCubeDCServo(serial_num);
device.Connect(serial_num);
device.WaitForSettingsInitialized(5000);
%device.GetDCPIDParams(); % Not the PID params we need to adjust, yet.

% Configure Stage 
% (This is, apparently, necessary.  Will encounter strange errors if not executed.)
motorSettings = device.LoadMotorConfiguration(serial_num);
motorSettings.DeviceSettingsName = 'KDC101';
% Update the RealToDeviceUnit converter
motorSettings.UpdateCurrentConfiguration();

% Push settings down to the device.
MotorDeviceSettings = device.MotorDeviceSettings;
device.SetSettings(MotorDeviceSettings, true, false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
device.StartPolling(250); % Units: [ms]
pause(1); % Pause to ensure device is enabled  -- is this really necessary??

% ***Home the motor before use***
fprintf('Homing motor... \n'); 
device.Home(timeout_val);
device.MoveTo(init_pos, timeout_val);
end