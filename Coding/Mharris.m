function varargout= Mharris(A,B,varargin)
%% detect 3D
    detect_bug = numel(size(A))*numel(size(B));
    if detect_bug~=9&&detect_bug~=4
        error('The picture dimensions must be consistent! ')
        
    end
    
    if numel(size(A))>2
        A_gray =im2double(rgb2gray(A));
    else
        A_gray = im2double(A);
    end
    
    if numel(size(B))>2
        B_gray =im2double(rgb2gray(B));
    else
        B_gray = im2double(B);
    end
    
    %% size
    [height_wrap, width_wrap] = size(A_gray);
    [height_unwrap, width_unwrap] = size(B_gray);
    
    
    %%  find the cornet points in these two image
    [x_A, y_A, v_A, R1] = harris(A_gray, 2, 0.0, 2);
    [x_B, y_B, v_B, R2] = harris(B_gray, 2, 0.0, 2);
    
    %% （ANMS） Adaptive non-maximum suppression
    ncorners = 500;
    [x_A, y_A, ~] = ada_nonmax_suppression(x_A, y_A, v_A, ncorners);
    [x_B, y_B, ~] = ada_nonmax_suppression(x_B, y_B, v_B, ncorners);
    
    %%   get the features points
    sigma = 7;
    [des_A] = GFD(A_gray, x_A, y_A, sigma);
    [des_B] = GFD(B_gray, x_B, y_B, sigma);
    
    %%  distance A and B
    dist = distance(des_A,des_B);
    [ord_dist, index] = sort(dist, 2);
    %% ratio 
    % the ratio is better than distance 
    % the threshold is the tolerance
    ratio = ord_dist(:,1) ./ ord_dist(:,2);
    threshold = 0.5;
    idx = ratio < threshold;
    x_A = x_A(idx);
    y_A = y_A(idx);
    x_B = x_B(index(idx,1));
    y_B = y_B(index(idx,1));
    npoints = length(x_A);
    
    %% 使用4点随机抽样一致计算鲁棒单应性估计，保持第一张图像不扭曲。
    matcher_A = [y_A, x_A, ones(npoints,1)]'; %!!! previous x is y and y is x,
    matcher_B = [y_B, x_B, ones(npoints,1)]'; %!!! so switch x and y here.
    [hh, ~] = rmy(matcher_B, matcher_A, npoints, 10);
    
    %% 使用反向旋转方法确定整个图像的大小
    [newH, newW, newX, newY, xB, yB] = GNS(hh, height_wrap, width_wrap, height_unwrap, width_unwrap);
    
    [X,Y] = meshgrid(1:width_wrap,1:height_wrap);
    [XX,YY] = meshgrid(newX:newX + newW - 1, newY:newY + newH - 1);
    AA = ones(3,newH * newW);
    AA(1,:) = reshape(XX,1,newH * newW);
    AA(2,:) = reshape(YY,1,newH * newW);
    AA = hh * AA;
    XX = reshape(AA(1,:) ./ AA(3,:), newH, newW);
    YY = reshape(AA(2,:) ./ AA(3,:), newH, newW);
    
    %% Interp2 
    if numel(size(A))==2&&numel(size(B))==2
        newImage(:,:) = interp2(X, Y, double(A(:,:)), XX, YY);
        
    elseif numel(size(A))>2&&numel(size(B))>2
        newImage(:,:,1) = interp2(X, Y, double(A(:,:,1)), XX, YY);
        newImage(:,:,2) = interp2(X, Y, double(A(:,:,2)), XX, YY);
        newImage(:,:,3) = interp2(X, Y, double(A(:,:,3)), XX, YY);
    end
    %% output 
    if nargin == 2
        varargout{1} = Mblend(newImage, B, xB, yB);
    elseif  nargin == 3
        varargout{1} = Mblend(newImage, B, xB, yB);
        varargout{2} = R1;
        varargout{3} = R2;
    end
    
end
    
    