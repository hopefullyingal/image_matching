clear;
clc;
%% image read
buildingScene = imageSet('test5');

image_A = read(buildingScene,2);
image_B = read(buildingScene,1);

im1 = im2double(im2bw(image_A));
im2 = im2double(im2bw(image_B));
[height_A, width_A] = size(im1);
[height_B, width_B] = size(im2);

%% detect
[x_A, y_A, ~] = harris(im1, 2, 0.0, 2);   %角点检测
[x_B, y_B, ~] = harris(im2, 2, 0.0, 2);


[des_A] = getFeatureDescriptor(im1, x_A, y_A);%获取特征
[des_B] = getFeatureDescriptor(im2, x_B, y_B);

[desA,~] =size(des_A);
[desB,~] =size(des_B);
%% calculate distance

dist = (ones(desB, 1) * sum((des_A.^2)', 1))' + ...
    ones(desA, 1) * sum((des_B.^2)',1) -2.*(des_A*(des_B'));


[ord_dist, index] = sort(dist, 2);

%% threshold
%选择小于0.5的点
ratio = ord_dist(:,1)./ord_dist(:,2);
threshold = 0.5;
idx = ratio<threshold;

x_A = x_A(idx);
y_A = y_A(idx);
x_B = x_B(index(idx,1));
y_B = y_B(index(idx,1));

npoints = length(x_A);


% USE 4-POINT RANSAC TO COMPUTE A ROBUST HOMOGRAPHY ESTIMATE
% KEEP THE FIRST IMAGE UNWARPED, WARP THE SECOND TO THE FIRST
matcher_A = [y_A, x_A, ones(npoints,1)]'; 
matcher_B = [y_B, x_B, ones(npoints,1)]';
[Mran, ~] = ransacfithomography(matcher_B, matcher_A, npoints, 10);%变换关系


% USE INVERSE WARP METHOD
% DETERMINE THE SIZE OF THE WHOLE IMAGE

[X,Y] = meshgrid(1:width_A,1:height_A);
Mmat = ones(3,height_A*width_A);
Mmat(1,:) = reshape(X,1,height_A*width_A);
Mmat(2,:) = reshape(Y,1,height_A*width_A);

% DETERMINE THE FOUR CORNER OF NEW IMAGE
new = Mran\Mmat;
new_left = fix(min([1,min(new(1,:)./new(3,:))]));
new_right = fix(max([width_B,max(new(1,:)./new(3,:))]));
new_top = fix(min([1,min(new(2,:)./new(3,:))]));
new_bottom = fix(max([height_B,max(new(2,:)./new(3,:))]));

newH = new_bottom - new_top + 1;
newW = new_right - new_left + 1;
newX = new_left;
newY = new_top;
xB = 2 - new_left;
yB = 2 - new_top;


[X,Y] = meshgrid(1:width_A,1:height_A);
[X_v,Y_v] = meshgrid(newX:newX+newW-1, newY:newY+newH-1);
Newimg = ones(3,newH*newW);
Newimg(1,:) = reshape(X_v,1,newH*newW);
Newimg(2,:) = reshape(Y_v,1,newH*newW);

Newimg = Mran*Newimg;
X_F = reshape(Newimg(1,:)./Newimg(3,:), newH, newW);
Y_F = reshape(Newimg(2,:)./Newimg(3,:), newH, newW);

% 二维插值
newImage(:,:,1) = interp2(X, Y, double(image_A(:,:,1)), X_F, Y_F);
newImage(:,:,2) = interp2(X, Y, double(image_A(:,:,2)), X_F, Y_F);
newImage(:,:,3) = interp2(X, Y, double(image_A(:,:,3)), X_F, Y_F);

%混合拼接
[newImage] = blend(newImage, image_B, xB, yB);

imshow(uint8(newImage));

