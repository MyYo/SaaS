function move_stage_at_vel(device, velocity)
    if velocity < 0
        dir = Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Backward;
    else
        dir = Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Forward;
    end
    speed = abs(velocity) * 1e6;
    device.MoveContinuousAtVelocity(dir, speed);
    pos = System.Decimal.ToDouble(device.Position);
    fprintf('The motor position is: %d \n',pos);
end