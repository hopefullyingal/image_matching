function  image_stitching(A,B,varargin)
%@Author    ;HuangWeiChen
%@Time      :2021/5/5


% Input:
% input_A :image 1
% input_B : image 2

% Output:
% output_image - combined new image

%@Note  :No return ,show the combined image directly
%@Power ;1. Detecting the input image is null or not
%
%         2.if the input is too big and the use choose the harris,
%         it will run a long time ,so I detect the image size.
%          When the size is bigger than 2000,I suggest the use to using
%          SURF,so I wirte the input code . User choose YES
%          --SURF,whether NO --just run the harris
%         3. it will show the Corner point
%
%@TODO  :The SURF do only run with gray image. If you want run wiht
%        GRB,maybe bulid a new file.
%       : harris is too slow!!!!!!!!!!!!!!!!!!!

%% detect input
if isempty(A)
    error('the first image is empty!');
elseif isempty(B)
    error('the second image is empty!');
end



Size_A =max(size(A));
Size_B =max(size(B));

dimension_A=numel(size(A));
dimension_B = numel(size(B));

if dimension_B *dimension_A~=9&&dimension_B *dimension_A~=4
    error('the input image dimension is not correct,they should have the same dimension');
end

%% image is too big
times = 1;

while(1)
    if times ==1
        if  Size_A>2000||Size_B>2000
            disp("the image is too big,we think you should use SURF");
            disp("Do you want to use SURF?")
            disp("Yes   or   No");
            
        else
            flag = -1;
            break;
        end
        
    else
        string = input('','s');
        if string =="Yes"
            flag = 1;
            break;
        elseif string =="No"
            flag = -1;
            break;
        else
            disp("Please input the right string!!");
        end
        
    end
    times =times +1;
    
    
end

%% choose a way
if flag == 1
    MSURF(A ,B);
else
    if nargin == 3
        if varargin{1} ~="harris"&&varargin{1} ~="SURF"
            error('the first input string is incorrect! ');
            
        elseif  varargin{1} =="SURF"
            MSURF(A ,B);
        elseif varargin{1} =="harris"
            
            [newImage]= Mharris(A,B);
            figure('Name',"Harris,3");
            imshow(uint8(newImage));
            
            
        end
    elseif nargin == 2
        [newImage]= Mharris(A,B);
        figure('Name',"Harris,2")
        imshow( uint8(newImage));
    elseif nargin == 4
        if varargin{2}=="write"||varargin{2}=="Corner"
            if varargin{2}=="write"
                Mwrite = 1;
            else
                Mwrite = 0;
            end
            if varargin{2}=="Corner"
                Mcorner = 1;
            else
                Mcorner = 0;
                
            end
        else
            error('the second input string is incorrect');
        end
        
        if varargin{1} ~="harris"&&varargin{1} ~="SURF"
            error('the first input string is incorrect! ');
            
        elseif  varargin{1} =="SURF"
 
                output = MSURF(A ,B);

            
            
            
            if Mwrite ==1  %write
                saveas(output,'Output\SURF','png');
            elseif Mcorner ==1
                error("the SURF don't have the corner points!!");
            end
            
            
        elseif varargin{1} =="harris"
            
            [newImage,R1,R2]= Mharris(A,B,varargin{2});
            if Mcorner ==1
                figure('Name','Harris 3');
                imshow( uint8(newImage));
                
                figure('Name','Corner');
                subplot(121);
                imshow(R1);
                title('First');
                
                subplot(122);
                imshow(R2);
                title('Second');
                
            elseif Mwrite ==1
                figure('Name','Harris write');
                imshow( uint8(newImage));
                imwrite(uint8(newImage),'Output\Harris.png');
            else
                error('the input string is bug !!');
            end
            
        end
        
    end
end



end







