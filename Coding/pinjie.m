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

% ��ͼƬ���ж�ȡ��һ��ͼ��
I1 = read(buildingScene, 1);
I2 = read(buildingScene, 2);

%% imfliter 
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);


%%  Backup
imgs=[I1,I2];
figure,imshow(imgs);%������ʾ������ƴ��ͼ��
title('��ƴ��ͼ��');
img1=I1;
img2=I2;
imageSize=size(img1);

%% SURF
%input  :image
%Output :SURFPoints

points_1=detectSURFFeatures(img1);
points_2=detectSURFFeatures(img2);%���SURF������


%% �������� 

[img1Features, extractPoints_1] = extractFeatures(img1, points_1);%ʹ��64ά������ʾ����������,
%��һ�����صĲ�����Ϊÿ���������Ӧ�����������ӣ��ڶ���������������
[img2Features, extractPoints_2] = extractFeatures(img2, points_2);

%% ����������ƥ��
boxPairs = matchFeatures(img1Features, img2Features);%����������ƥ��
 
%% find the Features points in all SURF points
matchedimg1Points = extractPoints_1(boxPairs(:, 1));%�ڶ�������:���Բ��ӣ���Ϊ��Ϊn��1�еĽṹ������
matchedimg2Points = extractPoints_2(boxPairs(:, 2));

%%
[tform, inlierimg2Points, inlierimg1Points] = ...
estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'similarity');%��Ӱ�任��tfromӳ����1�ڵ㵽���2�ڵ�
%�ú���ʹ���������һ���ԣ�RANSAC���㷨�ı���MSAC�㷨ʵ�֣�ȥ����ƥ���
%The returned geometric transformation matrix maps the inliers in matchedPoints1
%to the inliers in matchedPoints2.���صļ���ӳ�����ӳ���һ�����ڵ㵽�ڶ������ڵ�

showMatchedFeatures(I1, I2, inlierimg1Points, ...
    inlierimg2Points, 'montage');
title('Matched Points (Inliers Only)');%��ʾƥ����

%%
Rfixed = imref2d(size(I1)); %�ڲ���������������֮��Ĺ�ϵ��

[registered2, Rregistered] = imwarp(I2, tform);%ͼ����Ӱ�任����ͼ1��Ϊ��׼

figure()
imshowpair(I1,Rfixed,registered2,Rregistered,'blend');%ͼ��ƴ��
%blend�� ����һ�ֻ��͸����������
title('ƴ��ͼ��');
