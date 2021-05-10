function [newH, newW, newX, newY, xB, yB] = getNewSize(hh, height_wrap, width_wrap, height_unwrap, width_unwrap1)
% Calculate the size of new mosaic
% Input:
% transform - homography matrix
% h1 - height of the unwarped image
% w1 - width of the unwarped image
% h2 - height of the warped image
% w2 - height of the warped image
% Output:
% newH - height of the new image
% newW - width of the new image
% x1 - x coordate of lefttop corner of new image
% y1 - y coordate of lefttop corner of new image
% x2 - x coordate of lefttop corner of unwarped image
% y2 - y coordate of lefttop corner of unwarped image
% 
% Yihua Zhao 02-02-2014
% zhyh8341@gmail.com
%

% CREATE MESH-GRID FOR THE WARPED IMAGE
[X,Y] = meshgrid(1:width_wrap,1:height_wrap);
Mmat = ones(3,height_wrap*width_wrap);
Mmat(1,:) = reshape(X,1,height_wrap*width_wrap);
Mmat(2,:) = reshape(Y,1,height_wrap*width_wrap);

% DETERMINE THE FOUR CORNER OF NEW IMAGE
new = hh\Mmat;
new_left = fix(min([1,min(new(1,:)./new(3,:))]));
new_right = fix(max([width_unwrap1,max(new(1,:)./new(3,:))]));
new_top = fix(min([1,min(new(2,:)./new(3,:))]));
new_bottom = fix(max([height_unwrap,max(new(2,:)./new(3,:))]));

newH = new_bottom - new_top + 1;
newW = new_right - new_left + 1;
newX = new_left;
newY = new_top;
xB = 2 - new_left;
yB = 2 - new_top;

