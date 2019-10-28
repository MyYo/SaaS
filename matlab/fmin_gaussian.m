function coeffs = fmin_gaussian(I, downsample_factor)

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


% TEMPORARY
% i = find(I(:)==max(I(:)),1,'first');
% aInitial = [xx(i),yy(i), n/2, max(I(:)),min(I(:))];
% aInitial = [xx(i), yy(i), n, max(I(:)),min(I(:))];
% TEMPORARY

persistent aPrev;
if isempty(aPrev)
    i = find(I(:)==max(I(:)),1,'first');
    aInitial = [xx(i),yy(i), n/2, max(I(:)),min(I(:))];
    fprintf("Using max as initial guess\n");
else
    aInitial = aPrev;
end

[aBest, ~, exitflag] = fminsearch(@(a)( sum(sum((f(a)-I).^2))),aInitial);
if exitflag <= 0 % no solution found
    aBest = aPrev;
end
coeffs = aBest.*downsample_factor;
aPrev = aBest;

end