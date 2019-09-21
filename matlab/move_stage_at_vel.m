function move_stage_at_vel(device, velocity)
    persistent prev_dir;
    if velocity < 0
        dir = Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Backward;
    else
        dir = Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Forward;
    end
    if isempty(prev_dir)
        prev_dir = dir;
    else
        if prev_dir ~= dir
            device.Stop(5000);
            fprintf('changing direction...\n');
            prev_dir = dir;
        end
    end
    speed = abs(velocity) * 1e6;
    device.MoveContinuousAtVelocity(dir, speed);
%     pos = System.Decimal.ToDouble(device.Position);
%     fprintf('The motor position is: %d \n',pos);
end