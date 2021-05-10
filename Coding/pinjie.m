%@Author    ; Haung WeiChen
%@Time      :2021/5/2

%@Power     ;Image stitching
%@ Input:   :
            % input_A - filename of  image 1
            % input_B - filename of image 2
% @Output   :
            % output_image - combined new image
            
%@Function  ;detectSURFFeatures
%            matchFeatures
% extractFeatures


%@TODO      ;shadow

%@Bug       :only gray image can do


clc;
clear ;
close all;
%% Input
buildingScene = imageSet('test5');

% 从图片集中读取第一幅图像
I1 = read(buildingScene, 1);
I2 = read(buildingScene, 2);

%% imfliter 
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);


%%  Backup
imgs=[I1,I2];
figure,imshow(imgs);%并排显示两幅待拼接图像
title('待拼接图像');
img1=I1;
img2=I2;
imageSize=size(img1);

%% SURF
%input  :image
%Output :SURFPoints

points_1=detectSURFFeatures(img1);
points_2=detectSURFFeatures(img2);%检测SURF特征点


%% 特征向量 

[img1Features, extractPoints_1] = extractFeatures(img1, points_1);%使用64维向量表示特征描述子,
%第一个返回的参数即为每个特征点对应的特征描述子，第二个参数是特征点
[img2Features, extractPoints_2] = extractFeatures(img2, points_2);

%% 用于特征点匹配
boxPairs = matchFeatures(img1Features, img2Features);%特征描述子匹配
 
%% find the Features points in all SURF points
matchedimg1Points = extractPoints_1(boxPairs(:, 1));%第二个参数:可以不加，因为其为n行1列的结构体数组
matchedimg2Points = extractPoints_2(boxPairs(:, 2));

%%
[tform, inlierimg2Points, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'similarity');%射影变换，tfrom映射点对1内点到点对2内点
%该函数使用随机样本一致性（RANSAC）算法的变体MSAC算法实现，去除误匹配点
%The returned geometric transformation matrix maps the inliers in matchedPoints1
%to the inliers in matchedPoints2.返回的几何映射矩阵映射第一参数内点到第二参数内点

showMatchedFeatures(I1, I2, inlierimg1Points, ...
    inlierimg2Points, 'montage');
title('Matched Points (Inliers Only)');%显示匹配结果

%%
Rfixed = imref2d(size(I1)); %内部坐标与世界坐标之间的关系。

[registered2, Rregistered] = imwarp(I2, tform);%图像射影变换，以图1作为基准

figure()
imshowpair(I1,Rfixed,registered2,Rregistered,'blend');%图像拼接
%blend’ 这是一种混合透明处理类型
title('拼接图像');
