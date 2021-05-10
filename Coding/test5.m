% 以图像集的方法加载图片
% buildingDir = fullfile(toolboxdir('vision'), 'test5');
buildingScene = imageSet('test5');

% 显示要拼接的所有图片
montage(buildingScene.ImageLocation)


% 从图片集中读取第一幅图像
I = read(buildingScene, 1);

% 将图像转为灰度图，再提取I(1)的特征点，用的是surf算法。
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% 初始化所有变换的恒等矩阵。
tforms(buildingScene.Count) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:buildingScene.Count

% Store points and features for I(n-1).
% 存储前一图像的特征点坐标和值。
pointsPrevious = points;
featuresPrevious = features;

% Read I(n).
% 读取第n张图片。
I = read(buildingScene, n);

% Detect and extract SURF features for I(n).
%检测和提取surf特征值。
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% 匹配I(n)和I(n-1)之间对应的特征点
indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);

matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

% 用MSAC算法计算几何变化。
tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev, ...
'projective','Confidence', 99.9, 'MaxNumTrials', 2000);

% 计算T(1) * … * T(n-1) * T(n)
tforms(n).T = tforms(n-1).T * tforms(n).T;
end

imageSize = size(I);  % 所有的图像尺寸都是一样的

% 对每个投影变化找到输出的空间坐标限制值。
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end


avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);


Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = Tinv.T * tforms(i).T;
end


for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% 找到输出空间限制的最大最小值
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% 全景图的宽高
width  = round(xMax - xMin);
height = round(yMax - yMin);

% 生成空数据的全景图
panorama = zeros([height width 3], 'like', I);


blender = vision.AlphaBlender('Operation', 'Binary mask', ...
                              'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:buildingScene.Count

    I = read(buildingScene, i);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
end

figure
imshow(panorama)
