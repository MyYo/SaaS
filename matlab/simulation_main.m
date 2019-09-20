clear; close all; clc;

% parameters
input_beam.y = 0;
input_beam.width = 1.8;
% input_beam.theta_top = 0.000318;
% input_beam.theta_bot = -0.000318;
input_beam.theta_top = 0;
input_beam.theta_bot = 0;


lens.f = 500;
lens.R = 230;
lens.type = 'planoconvex';
lens.n = 1.460;
lens.dia = 25.4;
lens.t_c = 2.4;
lens.t_e = 2.0;

d_cam = 600;
d_lens = 50;
y_max = 0.99*(lens.dia - (input_beam.width/2));
y_min = 1.01*(0 + (input_beam.width/2));
v_max = 2.4; % mm/s
    
dT = 0.1;
T = 10;
delay = 0.7;

t = 0:dT:T;
N = length(t);
y_in = zeros(N, 1);
y_out = zeros(N, 1);
v_in = zeros(N, 1);
v_in(1) = 0;
y_ramp = -0.5:-1/N:-1.5;
y_step = -1*ones(N, 1);

fh = figure;
% axis([0 T 0 40]);
subplot(5, 2, 5);
an_input_y = animatedline('Marker', '.', 'Color', 'b');
ylabel('Input y [mm]');
subplot(5, 2, 7);
an_input_theta = animatedline('Marker', '.', 'Color', 'b');
ylabel('Input \Theta [rad]');
subplot(5, 2, 9);
an_input_v = animatedline('Marker', '.', 'Color', 'b');
ylabel('Requested Velocity [mm/s]');

subplot(5, 2, 6);
an_output_y = animatedline('Marker', '.', 'Color', 'r');
an_des_y = animatedline('Marker', '.','Color', 'k');
ylabel('Output y [mm]');
subplot(5, 2, 8);
an_output_width = animatedline('Marker', '.', 'Color', 'r');
ylabel('Beam width [um]');
xlabel('Time [s]');

% simulate
j = 1;
y_dot = 0;
for i = 1:T/dT
    addpoints(an_input_y, dT*i, input_beam.y);
    y_in(i) = input_beam.y;
    input_theta = (input_beam.theta_top + input_beam.theta_bot)/2;
    addpoints(an_input_theta, dT*i, input_theta);
    
    [y, beam_width] = simulate_ray(input_beam, lens, d_lens, d_cam, false, fh);
    y = y + 0.1*y*randn; % simulate noise
    y_out(i) = y;
    y_des = y_step(i);
    addpoints(an_output_y, dT*i, y);
    addpoints(an_output_width, dT*i, beam_width*1000);
    addpoints(an_des_y, dT*i, y_des);
    
    % specify how input beam changes with time
    % position control
    % input_beam.y = pos_pid_controller(y, y_des, y_max, y_min);
    
    % velocity control
    if delay ~= 0
        if i == (uint8(delay*j/dT))
            y_dot = velocity_controller(y, y_des, v_max);
            j = j+1;
        end
    else
        y_dot = velocity_controller(y, y_des, v_max);
    end
    
    v_in(i) = y_dot;
    input_beam.y = input_beam.y + y_dot*dT;
    addpoints(an_input_v, dT*i, y_dot);
end

function y = pos_pid_controller(y, y_des, y_max, y_min)
    persistent error_sum
    kp = -1; 
    ki = -1;
    
    if isempty(error_sum)
        error_sum = 0;
    end
    error_sum = error_sum + (y_des-y);
    y = kp * (y_des-y) + ki * error_sum;
    
    if y > y_max
        % cap max y
        y = y_max;
        % anti-windup
        error_sum = error_sum - (y_des-y);
    elseif y < y_min
        y = y_min;
        error_sum = error_sum - (y_des-y);
    end
end

