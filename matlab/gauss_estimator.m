% clc; close all; clear;
n = 1024;
% noise = 0.5*rand(n);
% I = exp(-((xx-690).^2+(yy-530).^2)./(20000))+noise;
% I = im2double(imread('20190801_SM_Gaussian_40mA_002.bmp'));
% I = I(1:n, 1:n);
coeffs = fmin_gaussian(Data, 16);

figure;
imshow(Data);
hold on;
plot(coeffs(1), coeffs(2), 'r.','MarkerSize', 10);
ang = 0:pi/64:2*pi;
r = 2*coeffs(3); % 2 std devs
circle_x = r*cos(ang) + coeffs(1);
circle_y = r*sin(ang) + coeffs(2);
plot(circle_x, circle_y, 'r');


function coeffs = fmin_gaussian(I, downsample_factor)

tic;
n = length(I);
if downsample_factor > 1
    n = n/downsample_factor;
    I_ds = zeros(n, n);
    for i = 1:n
        for j = 1:n
            I_ds(i, j) = I(downsample_factor*i, downsample_factor*j);
        end
    end
    I = I_ds;
end
x = 1:n;
y = 1:n;
[xx,yy] = meshgrid(x,y);

f = @(a) ((a(4)-a(5))*exp(-((xx-a(1)).^2+(yy-a(2)).^2)/(2*a(3)^2))+a(5));
persistent aPrev;
if isempty(aPrev)
    i = find(I(:)==max(I(:)),1,'first');
    aInitial = [xx(i),yy(i), n/2, max(I(:)),min(I(:))];
else
    aInitial = aPrev;
end

aBest = fminsearch(@(a)( sum(sum((f(a)-I).^2))),aInitial);
aPrev = aBest;
coeffs = aBest.*downsample_factor;
toc;

end
