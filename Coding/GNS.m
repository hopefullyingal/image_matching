function [new_H, new_W, x1, y1, x2, y2] = GNS(transform, h2, w2, h1, w1)
% 计算新图像的大小及相应坐标
% 输入：
% transform - 单应矩阵
% h - 基准图像的高度
% w - 基准图像的宽度
% 输出：
% new_H - 新图像高
% new_W - 新图像宽
% x1 - 新图像左上角的x坐标
% y1 - 新图像左上角的y坐标
% x2 - 基准图像左上角的x坐标
% y2 - 基准图像左上角的y坐标

% 创建扭曲图像的网格
[X,Y] = meshgrid(1:w2,1:h2);
Z_A = ones(3,h2 * w2);
Z_A(1,:) = reshape(X,1,h2 * w2);
Z_A(2,:) = reshape(Y,1,h2 * w2);

% 确定新图像的四顶点坐标
newA = transform \ Z_A;
new_l = fix(min([1,min(newA(1,:) ./ newA(3,:))]));
new_r = fix(max([w1,max(newA(1,:) ./ newA(3,:))]));
new_t = fix(min([1,min(newA(2,:) ./ newA(3,:))]));
new_b = fix(max([h1,max(newA(2,:) ./ newA(3,:))]));
new_H = new_b - new_t + 1;
new_W = new_r - new_l + 1;
x1 = new_l;
y1 = new_t;
x2 = 2 - new_l;
y2 = 2 - new_t;
end