a = rgb2gray(imread('test5\1.jpg'));
b = rgb2gray(imread('test5\2.jpg'));
c =size(b);
d = imresize(a ,c);
imshow(d);
imwrite(d,'1.jpg');