% paraxial ray simulation
function [y_output, beam_width] = simulate_ray(input_beam, lens, d_lens, d_cam, approximation, fig)
% tic;    
% fprintf('Input beam:\ny = %f\nbeam width = %f\nangular spread = %f\n\n', ...
%     input_beam.y, input_beam.width, input_beam.theta_top - input_beam.theta_bot);

y_top = input_beam.y + input_beam.width/2;
y_bot = input_beam.y - input_beam.width/2;

% propagation matrix
M_propagation = @(d)[1, d; 0, 1];

% thin lens matrix
M_thinlens = [1, 0; -1/lens.f, 1];

% animate
figure(fig);
subplot(5, 2, [1 2 3 4]);
cla;
hold on;
% axis equal;
axis([0 d_lens+d_cam -100 100]);
ys = linspace(y_top, y_bot);
thetas = linspace(input_beam.theta_top, input_beam.theta_bot);

% plot lens
if lens.type == 'planoconvex'
    ang_width = asin((lens.dia/2)/lens.R); 
    plot_arc(pi-ang_width, pi+ang_width, lens.R, d_lens+lens.R-lens.t_c, lens.dia/2);
    l = d_lens;
    line([l l],[0 lens.dia], 'Color', [0 0 0]);
    line([l - lens.t_e, l], [0 0], 'Color', [0 0 0]);
    line([l - lens.t_e, l], [lens.dia lens.dia], 'Color', [0 0 0]);
end
    
for i = 1:length(ys)
    ray = [ys(i); thetas(i)];

    % planoconvex lens
    incident_ray = M_propagation(d_lens)*ray;
    y = incident_ray(1);
    M_spherical = [1, 0; -(lens.n-1)/(lens.n*lens.R), 1/lens.n];
    d = sqrt(lens.R^2-(lens.dia/2-y)^2) - (lens.R-lens.t_c);
    if y > lens.dia || y < 0 
        d = 0;
    end
    M_planar = [1, 0; 0, lens.n/1];
    I = eye(2);

    if approximation
        % thin lens approximation
        z_list = [d_lens, d_cam];
        M_list = {I, M_thinlens};
    else
        % using snells law
        z_list = [d_lens - d, d, d_cam]; % distance b/w optical components
        M_list = {I, M_spherical, M_planar}; % matrices of optical components
        assert(length(z_list) == length(M_list));
    end

    % plot rays
    z2 = 0;
    for j = 1:length(z_list)
        M = cell2mat(M_list(j));
        M_prop = M_propagation(z_list(j));
        y1 = ray(1);
        z1 = z2;
        if y1 > lens.dia || y1 < 0 
            M = I;
        end
        ray = M_prop * M * ray;
        y2 = ray(1);
        z2 = z1+z_list(j);
        plot([z1, z2], [y1, y2], 'Color', [1 0 0]);       
    end

    if i == 1
        y_top = ray(1);
        theta_top = ray(2);
    elseif i == length(ys)
        y_bot = ray(1);
        theta_bot = ray(2);
    end     
end

drawnow;

if y_top < y_bot
    temp = y_bot;
    y_bot = y_top;
    y_top = temp;
    
    temp = theta_bot;
    theta_bot = theta_top;
    theta_top = temp;
end

y_output = (y_top+y_bot)/2;
beam_width = y_top-y_bot;

% fprintf('Output beam:\ny = %f\nbeam width = %f\nangular spread = %f\n\n', ...
%     y_output, beam_width, theta_top-theta_bot);
% toc;
end


% helper functions
function M = construct_lens_M(y, lens)
    if lens.type == 'planoconvex'
        M_spherical = [1, 0; -(lens.n-1)/(lens.n*lens.R), 1/lens.n];
        d = sqrt(lens.R^2-(lens.dia/2-y)^2) - (lens.R-lens.t_c);
        M_planar = [1, 0; 0, lens.n/1];
        M_propagation = [1, d; 0, 1];
        M = M_planar * M_propagation * M_spherical;
    end
end

function plot_arc(start_angle, end_angle, radius, x_offset, y_offset)
    t = linspace(start_angle, end_angle);
    x = radius*cos(t) + x_offset;
    y = radius*sin(t) + y_offset;
    plot(x, y, 'Color', [0 0 0]);
end
