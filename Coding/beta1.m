% 1. 加载两个图像，转换为双倍和灰度。
% 2. 检测两幅图像的特征点。
% 3. 在两幅图像的每个关键点周围提取固定大小的通道，并通过简单地将每个通道中的像素值“平坦化”到一维向量来形成描述符。
% 4. 计算一张图像中的每个描述符与另一张图像中的每个描述符之间的距离。
% 5. 根据上述得到的两两描述符距离矩阵选择假定匹配。
% 6. 运行随机抽样一致来估计(1)仿射变换和(2)将一张图像映射到另一张图像上的单应性。
% 7. 使用估计的变换将一个图像扭曲到另一个图像上。
% 8. 创建一个足够大的新图像来容纳全景图，并将这两张图像合成到其中。
% 输入：
% input_A - 旋转图像的文件名
% input_B - 基准图像的文件名
% 输出：组合的图像


clc;
clear;
close all;


%% 获取图像信息

buildingScene = imageSet('test5');
A = read(buildingScene, 1);
B= read(buildingScene, 2);
[height_wrap, width_wrap,~] = size(A);
[height_unwrap, width_unwrap,~] = size(B);

%% 转换为灰度图像
A_gray = im2double(rgb2gray(A));
B_gray = im2double(rgb2gray(B));

%% 找到两个图像中的角点
[x_A, y_A, v_A, R1] = harris(A_gray, 2, 0.0, 2);
[x_B, y_B, v_B, R2] = harris(B_gray, 2, 0.0, 2);
subplot(1,2,1)
imshow(R1);
subplot(1,2,2)
imshow(R2);
title('角点');

%% 自适应非最大抑制（ANMS）
ncorners = 500;
[x_A, y_A, ~] = ada_nonmax_suppression(x_A, y_A, v_A, ncorners);
[x_B, y_B, ~] = ada_nonmax_suppression(x_B, y_B, v_B, ncorners);

%% 提取特征描述因子
sigma = 7;
[des_A] = GFD(A_gray, x_A, y_A, sigma);
[des_B] = GFD(B_gray, x_B, y_B, sigma);

%% 实现特征匹配
dist = distance(des_A,des_B);
[ord_dist, index] = sort(dist, 2);
%% 第一距离和第二距离的比值比直接使用距离更好。比率小于.5给出一个可接受的错误率。
ratio = ord_dist(:,1) ./ ord_dist(:,2);
threshold = 0.5;
idx = ratio < threshold;
x_A = x_A(idx);
y_A = y_A(idx);
x_B = x_B(index(idx,1));
y_B = y_B(index(idx,1));
npoints = length(x_A);

%% 使用4点随机抽样一致计算鲁棒单应性估计，保持第一张图像不扭曲。
matcher_A = [y_A, x_A, ones(npoints,1)]'; %!!! previous x is y and y is x,
matcher_B = [y_B, x_B, ones(npoints,1)]'; %!!! so switch x and y here.
[hh, ~] = rmy(matcher_B, matcher_A, npoints, 10);

%% 使用反向旋转方法确定整个图像的大小
[newH, newW, newX, newY, xB, yB] = GNS(hh, height_wrap, width_wrap, height_unwrap, width_unwrap);

[X,Y] = meshgrid(1:width_wrap,1:height_wrap);
[XX,YY] = meshgrid(newX:newX + newW - 1, newY:newY + newH - 1);
AA = ones(3,newH * newW);
AA(1,:) = reshape(XX,1,newH * newW);
AA(2,:) = reshape(YY,1,newH * newW);
AA = hh * AA;
XX = reshape(AA(1,:) ./ AA(3,:), newH, newW);
YY = reshape(AA(2,:) ./ AA(3,:), newH, newW);

%% 插值，将图像旋转为新图像
newImage(:,:,1) = interp2(X, Y, double(A(:,:,1)), XX, YY);
newImage(:,:,2) = interp2(X, Y, double(A(:,:,2)), XX, YY);
newImage(:,:,3) = interp2(X, Y, double(A(:,:,3)), XX, YY);

%% 使用交叉融合方法融合图像
[newImage] = blend(newImage, B, xB, yB);

%% 显示图像
figure;
imshow(uint8(newImage));


