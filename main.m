%@Author    ; Haung WeiChen
%@Time      :2021/5/2

%@Power     ;Image stitching
%@ Input:   :
            % input_A - filename of  image 1
            % input_B - filename of image 2
% @Output   :
            % output_image - combined new image
            
%@Function  ;detectSURFFeatures
%            matchFeatures
%            extractFeatures


%@TODO      ;shadow


clc;
clear;
close all;

%% read image
addpath('resource');
addpath('Image');
% user to choose the image he want
%%%%%%%%%%%%%%%%%%Input%%%%%%%%%%%%%%%%%%
% [fname ,pname ,index]=uigetfile();
% if index
%     str=[pname, fname];
%     A=rgb2gray(imread(str));
% end
% [fname ,pname ,index]=uigetfile();
% if index
%     str=[pname ,fname];
%     B=rgb2gray(imread(str));
% end
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% input :please input you image  flie path
%       :the first and the second is you choice image 
%       :image number is the way from left to right in you file
% run('lib/vlfeat-0.9.20/toolbox/vl_setup');
% s=imageSet('Image\family_house');
% img=read(s,1);
% size_1=size(img,1);
% size_bound = 400;
% if size_1>size_bound
%     img=imresize(img,size_bound/size_1);
% end
% imgs=zeros(size(img,1),size(img,2),size(img,3),s.Count,'like',img);
% 
% 
% t=cputime;
% for i=1:s.Count
%     new_img=read(s,i);
%     if size_1>size_bound
%         imgs(:,:,:,i)=imresize(new_img,size_bound/size_1);
%     else
%         imgs(:,:,:,i)=new_img;
%     end
%     
% end
% 
% imgs=imorder(imgs);
% panorama=create( imgs,1000, 0);
% imshow(panorama);


%%%%%%%%%%%%%%%%%%%TEST%%%%%%%%%%%%%%%%%%
imagePath = 'Image\eyes';
first = 1;
second = 2;
 buildingScene = imageSet(imagePath);
A = read(buildingScene, first);
B= read(buildingScene, second);

size_bound = 400;
size_1=size(A,1);
if size_1>size_bound
    A=imresize(A,size_bound/size_1);
end

size_1=size(B,1);
if size_1>size_bound
    B=imresize(B,size_bound/size_1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% run 
%%%%%%%%%%%%%%%%%%input image test%%%%%%%%%%%%%%%%%%%
A = rgb2gray(A);
B = rgb2gray(B);

%%%%%%%%%%%%%%%%%%%%%%%%normal-test%%%%%%%%%%%%%%%%%%%%


% image_stitching(A,B,'SURF','write');
% image_stitching(A,B,'harris');
image_stitching(A,B,'SURF');
% image_stitching(A,B);
% image_stitching(A,B,'harris','write');
% image_stitching(A,B,'harris','Corner');

%%%%%%%%%%%%%%%%%%%%% BUG-test%%%%%%%%%%%%%%%%%%%%%%%%%%%

% image_stitching(A,B,'harris','Write');
% image_stitching(A,B,'harris','corner');
% image_stitching(A,B,'SURF','corner');
% image_stitching(A,B,'Harri');
% image_stitching(A,B,'S');
% 






