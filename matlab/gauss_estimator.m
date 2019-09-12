clc; close all; clear;
n = 1024;
noise = 0.5*rand(n);
% I = exp(-((xx-690).^2+(yy-530).^2)./(20000))+noise;
I = im2double(imread('20190801_SM_Gaussian_40mA_002.bmp'));
I = I(1:n, 1:n);
coeffs = fmin_gaussian(I, 16);

figure;
imshow(I);
hold on;
plot(coeffs(1), coeffs(2), 'r.','MarkerSize', 10);
ang = 0:pi/64:2*pi;
r = 2*coeffs(3); % 2 std devs
circle_x = r*cos(ang) + coeffs(1);
circle_y = r*sin(ang) + coeffs(2);
plot(circle_x, circle_y, 'r');
