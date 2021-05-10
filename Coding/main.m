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


%%%%%%%%%%%%%%%%%%%TEST%%%%%%%%%%%%%%%%%%
imagePath = 'Image';
first = 5;
second = 6;
buildingScene = imageSet(imagePath);
A = read(buildingScene, first);
B= read(buildingScene, second);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% run 
%%%%%%%%%%%%%%%%%%input image test%%%%%%%%%%%%%%%%%%%
A = rgb2gray(A);
B = rgb2gray(B);

%%%%%%%%%%%%%%%%%%%%%%%%normal-test%%%%%%%%%%%%%%%%%%%%


% image_stitching(A,B,'SURF','write');
% image_stitching(A,B,'harris');
% image_stitching(A,B,'SURF');
image_stitching(A,B);
% image_stitching(A,B,'harris','write');
% image_stitching(A,B,'harris','Corner');

%%%%%%%%%%%%%%%%%%%%% BUG-test%%%%%%%%%%%%%%%%%%%%%%%%%%%

% image_stitching(A,B,'harris','Write');
% image_stitching(A,B,'harris','corner');
% image_stitching(A,B,'SURF','corner');
% image_stitching(A,B,'Harri');
% image_stitching(A,B,'S');






