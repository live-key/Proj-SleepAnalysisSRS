fs = 5;
t = 0:1/fs:30*1100 - 1/fs;
x = cos(2*pi*100*t) + randn(size(t));

N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(x):fs/2;