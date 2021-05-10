%only for RGB image homography

clc;
clear all;
close all
f = 'Retina OCTA_';
ext = 'bmp';
img1 = imread([f '1.' ext]);
img2 = imread([f '2.' ext]);

if size(img1,3)==1%to find whether input is RGB image
fprintf('error,only for RGB images\n');
end

img1Dup=rgb2gray(img1);%duplicate img1
img1Dup=double(img1Dup);

img2Dup=rgb2gray(img2);%duplicate img2
img2Dup=double(img2Dup);

% use Harris in both images to find corner.

[locs1] = Harris(img1Dup);
[locs2] = Harris(img2Dup);


%using NCC to find coorespondence between two images
[matchLoc1, matchLoc2] =  findCorr(img1Dup,img2Dup,locs1, locs2);

% use RANSAC to find homography matrix
[H ,inlierIdx] = estHomography(img1Dup,img2Dup,matchLoc2',matchLoc1');
 H  %#ok
[imgout]=warpTheImage(H,img1,img2);
% Harris detector
% The code calculates
% the Harris Feature Points(FP) 
% 
% When u execute the code, the test image file opened
% and u have to select by the mouse the region where u
% want to find the Harris points, 
% then the code will print out and display the feature
% points in the selected region.
% You can select the number of FPs by changing the variables 
% max_N & min_N
% A. Ganoun

function [locs] = Harris(frame)
% I=rgb2gray(frame);
% I =double(I);
I=frame;
%****************************
% imshow(frame);
% 
% waitforbuttonpress;
% point1 = get(gca,'CurrentPoint');  %button down detected
% rectregion = rbbox;  %%%return figure units
% point2 = get(gca,'CurrentPoint');%%%%button up detected
% point1 = point1(1,1:2); %%% extract col/row min and maxs
% point2 = point2(1,1:2);
% lowerleft = min(point1, point2);
% upperright = max(point1, point2); 
% ymin = round(lowerleft(1)); %%% arrondissement aux nombrs les plus proches
% ymax = round(upperright(1));
% xmin = round(lowerleft(2));
% xmax = round(upperright(2));
% 
% 
% %***********************************
% Aj=6;
% cmin=xmin-Aj; cmax=xmax+Aj; rmin=ymin-Aj; rmax=ymax+Aj;
 min_N=350;max_N=450;


%%%%%%%%%%%%%%Intrest Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma=1.4; Thrshold=20; r=4; 
dx = [-1 0 1; -1 0 1; -1 0 1]; % The Mask 
    dy = dx';
    %%%%%% 
    Ix = conv2(I, dx, 'same');   
    Iy = conv2(I, dy, 'same');
    g = fspecial('gaussian',5*sigma, sigma); %%%%%% Gaussien Filter
    
    %%%%% 
    Ix2 = conv2(Ix.^2, g, 'same');  
    Iy2 = conv2(Iy.^2, g, 'same');
    Ixy = conv2(Ix.*Iy, g,'same');
    %%%%%%%%%%%%%%
    k = 0.04;
    R11 = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;
    R11=(1000/max(max(R11)))*R11;  %make the largest one to be 1000
   
    R=R11;
   
    sze = 2*r+1;                  
    MX = ordfilt2(R,sze^2,ones(sze));% non-Maximun supression
    R11 = (R==MX)&(R>Thrshold);      
    count=sum(sum(R11(5:size(R11,1)-5,5:size(R11,2)-5)));
    
    
    loop=0;  %use adaptive threshold here
    while (((count<min_N)||(count>max_N))&&(loop<30))
        if count>max_N
            Thrshold=Thrshold*1.5;
        elseif count < min_N
            Thrshold=Thrshold*0.5;
        end
        
        R11 = (R==MX)&(R>Thrshold); 
        count=sum(sum(R11(5:size(R11,1)-5,5:size(R11,2)-5)));
        loop=loop+1;
    end
    
    
	R=R*0;
    R(5:size(R11,1)-5,5:size(R11,2)-5)=R11(5:size(R11,1)-5,5:size(R11,2)-5);% ignore the corners on the boundary
	[r1,c1] = find(R);
    PIP=[r1,c1];%% IP 
    locs=PIP;
end
