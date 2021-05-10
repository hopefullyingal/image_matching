% 1. ��������ͼ��ת��Ϊ˫���ͻҶȡ�
% 2. �������ͼ��������㡣
% 3. ������ͼ���ÿ���ؼ�����Χ��ȡ�̶���С��ͨ������ͨ���򵥵ؽ�ÿ��ͨ���е�����ֵ��ƽ̹������һά�������γ���������
% 4. ����һ��ͼ���е�ÿ������������һ��ͼ���е�ÿ��������֮��ľ��롣
% 5. ���������õ��������������������ѡ��ٶ�ƥ�䡣
% 6. �����������һ��������(1)����任��(2)��һ��ͼ��ӳ�䵽��һ��ͼ���ϵĵ�Ӧ�ԡ�
% 7. ʹ�ù��Ƶı任��һ��ͼ��Ť������һ��ͼ���ϡ�
% 8. ����һ���㹻�����ͼ��������ȫ��ͼ������������ͼ��ϳɵ����С�
% ���룺
% input_A - ��תͼ����ļ���
% input_B - ��׼ͼ����ļ���
% �������ϵ�ͼ��


clc;
clear;
close all;


%% ��ȡͼ����Ϣ

buildingScene = imageSet('test5');
A = read(buildingScene, 1);
B= read(buildingScene, 2);
[height_wrap, width_wrap,~] = size(A);
[height_unwrap, width_unwrap,~] = size(B);

%% ת��Ϊ�Ҷ�ͼ��
A_gray = im2double(rgb2gray(A));
B_gray = im2double(rgb2gray(B));

%% �ҵ�����ͼ���еĽǵ�
[x_A, y_A, v_A, R1] = harris(A_gray, 2, 0.0, 2);
[x_B, y_B, v_B, R2] = harris(B_gray, 2, 0.0, 2);
subplot(1,2,1)
imshow(R1);
subplot(1,2,2)
imshow(R2);
title('�ǵ�');

%% ����Ӧ��������ƣ�ANMS��
ncorners = 500;
[x_A, y_A, ~] = ada_nonmax_suppression(x_A, y_A, v_A, ncorners);
[x_B, y_B, ~] = ada_nonmax_suppression(x_B, y_B, v_B, ncorners);

%% ��ȡ������������
sigma = 7;
[des_A] = GFD(A_gray, x_A, y_A, sigma);
[des_B] = GFD(B_gray, x_B, y_B, sigma);

%% ʵ������ƥ��
dist = distance(des_A,des_B);
[ord_dist, index] = sort(dist, 2);
%% ��һ����͵ڶ�����ı�ֵ��ֱ��ʹ�þ�����á�����С��.5����һ���ɽ��ܵĴ����ʡ�
ratio = ord_dist(:,1) ./ ord_dist(:,2);
threshold = 0.5;
idx = ratio < threshold;
x_A = x_A(idx);
y_A = y_A(idx);
x_B = x_B(index(idx,1));
y_B = y_B(index(idx,1));
npoints = length(x_A);

%% ʹ��4���������һ�¼���³����Ӧ�Թ��ƣ����ֵ�һ��ͼ��Ť����
matcher_A = [y_A, x_A, ones(npoints,1)]'; %!!! previous x is y and y is x,
matcher_B = [y_B, x_B, ones(npoints,1)]'; %!!! so switch x and y here.
[hh, ~] = rmy(matcher_B, matcher_A, npoints, 10);

%% ʹ�÷�����ת����ȷ������ͼ��Ĵ�С
[newH, newW, newX, newY, xB, yB] = GNS(hh, height_wrap, width_wrap, height_unwrap, width_unwrap);

[X,Y] = meshgrid(1:width_wrap,1:height_wrap);
[XX,YY] = meshgrid(newX:newX + newW - 1, newY:newY + newH - 1);
AA = ones(3,newH * newW);
AA(1,:) = reshape(XX,1,newH * newW);
AA(2,:) = reshape(YY,1,newH * newW);
AA = hh * AA;
XX = reshape(AA(1,:) ./ AA(3,:), newH, newW);
YY = reshape(AA(2,:) ./ AA(3,:), newH, newW);

%% ��ֵ����ͼ����תΪ��ͼ��
newImage(:,:,1) = interp2(X, Y, double(A(:,:,1)), XX, YY);
newImage(:,:,2) = interp2(X, Y, double(A(:,:,2)), XX, YY);
newImage(:,:,3) = interp2(X, Y, double(A(:,:,3)), XX, YY);

%% ʹ�ý����ںϷ����ں�ͼ��
[newImage] = blend(newImage, B, xB, yB);

%% ��ʾͼ��
figure;
imshow(uint8(newImage));


