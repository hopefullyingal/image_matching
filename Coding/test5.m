% ��ͼ�񼯵ķ�������ͼƬ
% buildingDir = fullfile(toolboxdir('vision'), 'test5');
buildingScene = imageSet('test5');

% ��ʾҪƴ�ӵ�����ͼƬ
montage(buildingScene.ImageLocation)


% ��ͼƬ���ж�ȡ��һ��ͼ��
I = read(buildingScene, 1);

% ��ͼ��תΪ�Ҷ�ͼ������ȡI(1)�������㣬�õ���surf�㷨��
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% ��ʼ�����б任�ĺ�Ⱦ���
tforms(buildingScene.Count) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:buildingScene.Count

% Store points and features for I(n-1).
% �洢ǰһͼ��������������ֵ��
pointsPrevious = points;
featuresPrevious = features;

% Read I(n).
% ��ȡ��n��ͼƬ��
I = read(buildingScene, n);

% Detect and extract SURF features for I(n).
%������ȡsurf����ֵ��
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

% ƥ��I(n)��I(n-1)֮���Ӧ��������
indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);

matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

% ��MSAC�㷨���㼸�α仯��
tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev, ...
'projective','Confidence', 99.9, 'MaxNumTrials', 2000);

% ����T(1) * �� * T(n-1) * T(n)
tforms(n).T = tforms(n-1).T * tforms(n).T;
end

imageSize = size(I);  % ���е�ͼ��ߴ綼��һ����

% ��ÿ��ͶӰ�仯�ҵ�����Ŀռ���������ֵ��
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

% �ҵ�����ռ����Ƶ������Сֵ
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% ȫ��ͼ�Ŀ��
width  = round(xMax - xMin);
height = round(yMax - yMin);

% ���ɿ����ݵ�ȫ��ͼ
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
