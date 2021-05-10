function [descriptors] = getFeatureDescriptor(input_image, xp, yp)

npoints = length(xp);
descriptors = zeros(npoints,64);

for i = 1:npoints
patch = input_image(xp(i)-20:xp(i)+19, yp(i)-20:yp(i)+19);
patch = imresize(patch, .2);
descriptors(i,:) = reshape((patch - mean2(patch))./std2(patch), 1, 64); 
end
