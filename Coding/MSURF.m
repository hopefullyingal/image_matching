function output = MSURF(A ,B)


%% Input
dimension_A=numel(size(A));
dimension_B = numel(size(B));
if dimension_B *dimension_A==9
    color_flag = 1;
elseif dimension_B *dimension_A==4
    color_flag = 0;
else
    error('the input image dimension is not correct,they should have the same dimension');
end

%% imfliter
if color_flag ==1
    I1 = rgb2gray(A);
    I2 = rgb2gray(B);
elseif color_flag ==0
    I1 = (A);
    I2 = (B);

end

h = fspecial('gaussian',7,0.05);
I1 = imfilter(I1,h,'corr','replicate');
I2 = imfilter(I2,h,'corr','replicate');
I1 = imerode(I1,[0 1 0;0 1 0;0 1 0]);
I1 = imopen(I1,[0 0 0;1 1 1;0 0 0]);
I2 = imerode(I2,[0 1 0;0 1 0;0 1 0]);
I2 = imopen(I2,[0 0 0;1 1 1;0 0 0]);
%对原始图像滤波并采用纵向矩阵消除背景噪声和横向噪声，增大检测到的正确匹配点数目


%%  Backup

img1=I1;
img2=I2;


%% SURF
%input  :image
%Output :SURFPoints

points_1=detectSURFFeatures(img1);
points_2=detectSURFFeatures(img2);%检测SURF特征点


%% 特征向量

[img1Features, points_1] = extractFeatures(img1, points_1);%使用64维向量表示特征描述子,
%第一个返回的参数即为每个特征点对应的特征描述子，第二个参数是特征点
[img2Features, points_2] = extractFeatures(img2, points_2);

%% 用于特征点匹配
boxPairs = matchFeatures(img1Features, img2Features);%特征描述子匹配

%% find the Features points in all SURF points
matchedimg1Points = points_1(boxPairs(:, 1));%第二个参数:可以不加，因为其为n行1列的结构体数组
matchedimg2Points = points_2(boxPairs(:, 2));

%%
[tform, ~, ~] = ...
    estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'similarity');%射影变换，tfrom映射点对1内点到点对2内点
%该函数使用随机样本一致性（RANSAC）算法的变体MSAC算法实现，去除误匹配点
%The returned geometric transformation matrix maps the inliers in matchedPoints1
%to the inliers in matchedPoints2.返回的几何映射矩阵映射第一参数内点到第二参数内点

% showMatchedFeatures(I1, I2, inlierimg1Points, ...
%     inlierimg2Points, 'montage');
% title('Matched Points (Inliers Only)');%显示匹配结果

%%
Rfixed = imref2d(size(I1));

[registered2, Rregistered] = imwarp(I2, tform);%图像射影变换，以图1作为基准
% [registered1, Rregistered1] = imwarp(I1, tform);%以图2作为基准

output= imshowpair(I1,Rfixed,registered2,Rregistered,'blend');%图像拼接
title('SURF');
end

