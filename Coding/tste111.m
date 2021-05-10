
buildingDir = fullfile(toolboxdir('vision'), 'hhh');
buildingScene = imageSet('test5');



I = imread('test5\2.bmp');
% ��ͼ��תΪ�Ҷ�ͼ������ȡI(1)�������㣬�õ���surf�㷨��
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);
% ��ʼ�����б任�ĺ�Ⱦ���
tforms(buildingScene.Count) = projective2d(eye(3));

pointsPrevious = points;
featuresPrevious = features;

I =imread('test5\1.bmp');


%������ȡsurf����ֵ��
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% ƥ��������
indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);

matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

% ��MSAC�㷨���㼸�α仯��
tforms(2) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);


tforms(2).T = tforms(1).T * tforms(2).T;



imageSize = size(I); 
% �ҵ���������ֵ��
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
% ����ռ������Сֵ
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);
yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);
% ȫ��ͼ�Ŀ��
width  = round(xMax - xMin);
height = round(yMax - yMin);
% �յ�ȫ��ͼ
final = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');

xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

for i = 1:2
    I = read(buildingScene, i);
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
    % Overlay the warpedImage onto the panorama.
    final = step(blender, final, warpedImage, warpedImage(:,:,1));
end
imshow(final)
