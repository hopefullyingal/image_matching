function [xp, yp, value,h] = harris(input_image, sigma,thd, r)

g1 = fspecial('gaussian', 7, 1);
input_image = imfilter(input_image, g1);


h = fspecial('sobel');
Ix = imfilter(input_image,h,'replicate','same');
Iy = imfilter(input_image,h','replicate','same');

g = fspecial('gaussian',fix(6*sigma), sigma);

Ix2 = imfilter(Ix.^2, g, 'same').*(sigma^2); 
Iy2 = imfilter(Iy.^2, g, 'same').*(sigma^2);
Ixy = imfilter(Ix.*Iy, g, 'same').*(sigma^2);

R = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); 

R([1:20, end-20:end], :) = 0;
R(:,[1:20,end-20:end]) = 0;


d = 2*r+1; 
localmax = ordfilt2(R,d^2,true(d)); 
R = R.*(and(R==localmax, R>thd));
h= R;
[xp,yp,value] = find(R);
