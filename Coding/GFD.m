function [descriptors] = GFD(input_image, xp, yp, sigma)
% 提取非旋转不变特征描述因子
% 输入灰度值图像
% xp - 潜在特征点的x坐标
% yp - 潜在特征点的y坐标
% 输出描述因子的矩阵

% 用高斯核函数进行模糊
imf = fspecial('gaussian',5, sigma);      %高斯低通滤波模板，模板尺寸为5
blur_im = imfilter(input_image, imf, 'symmetric','full');     %对图像进行滤波，边界通过镜像映射拓展
xl = length(xp);
descriptors = zeros(xl,64);

for i = 1:xl
    patch = blur_im(xp(i)-20:xp(i)+19, yp(i)-20:yp(i)+19);
    patch = imresize(patch, .2);                        %缩小图像
    descriptors(i,:) = reshape((patch - mean2(patch)) ./ std2(patch), 1, 64); 
end
end