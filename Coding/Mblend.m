function [new_Im] = Mblend(w_im, uw_im, x, y)
% 基于交叉融合进行两幅图像的融合
% 输入：
% w_im - 旋转图像
% uw_im - 基准图像
% x - 基准图像左上角的x坐标
% y - 基准图像左上角的y坐标
% 输出新图像

% 获得覆盖变量

if numel(size(w_im))==2&&numel(size(uw_im))==2
    w_im(isnan(w_im)) = 0;    %旋转图像中NaN点取0
    mask_A = (w_im(:,:) > 0);
    new_Im = zeros(size(w_im));
    new_Im(y:y+size(uw_im,1) - 1, x:x + size(uw_im,2) - 1,:) = uw_im;
    mask = (new_Im(:,:) > 0);
    mask = mask_A & mask;
    
    % 获取覆盖区域
    [~,cl] = find(mask);
    left = min(cl);
    right = max(cl);
    mask = ones(size(mask));
    if(x < 2)
        mask(:,left:right) = repmat(linspace(0,1,right - left + 1),size(mask,1),1);
    else
        mask(:,left:right) = repmat(linspace(1,0,right - left + 1),size(mask,1),1);
    end
    
    % 混合每个通道
    w_im(:,:) = w_im(:,:) .* mask;
    
    
    % 反转α值
    if(x < 2)
        mask(:,left:right) = repmat(linspace(1,0,right - left + 1),size(mask,1),1);
    else
        mask(:,left:right) = repmat(linspace(0,1,right - left + 1),size(mask,1),1);
    end
    new_Im(:,:) = new_Im(:,:) .* mask;
    
    new_Im(:,:) = w_im(:,:) + new_Im(:,:);       %融合图像
    
    
elseif numel(size(w_im))>2&&numel(size(uw_im))>2
    w_im(isnan(w_im)) = 0;    %旋转图像中NaN点取0
    mask_A = (w_im(:,:,1) > 0 | w_im(:,:,2) > 0 | w_im(:,:,3) > 0);
    new_Im = zeros(size(w_im));
    new_Im(y:y+size(uw_im,1) - 1, x:x + size(uw_im,2) - 1,:) = uw_im;
    mask = (new_Im(:,:,1) > 0 | new_Im(:,:,2) > 0 | new_Im(:,:,3) > 0);
    mask = mask_A & mask;
    
    % 获取覆盖区域
    [~,cl] = find(mask);
    left = min(cl);
    right = max(cl);
    mask = ones(size(mask));
    if(x < 2)
        mask(:,left:right) = repmat(linspace(0,1,right - left + 1),size(mask,1),1);
    else
        mask(:,left:right) = repmat(linspace(1,0,right - left + 1),size(mask,1),1);
    end
    
    % 混合每个通道
    w_im(:,:,1) = w_im(:,:,1) .* mask;
    w_im(:,:,2) = w_im(:,:,2) .* mask;
    w_im(:,:,3) = w_im(:,:,3) .* mask;
    
    % 反转α值
    if(x < 2)
        mask(:,left:right) = repmat(linspace(1,0,right - left + 1),size(mask,1),1);
    else
        mask(:,left:right) = repmat(linspace(0,1,right - left + 1),size(mask,1),1);
    end
    new_Im(:,:,1) = new_Im(:,:,1) .* mask;
    new_Im(:,:,2) = new_Im(:,:,2) .* mask;
    new_Im(:,:,3) = new_Im(:,:,3) .* mask;
    new_Im(:,:,1) = w_im(:,:,1) + new_Im(:,:,1);       %融合图像
    new_Im(:,:,2) = w_im(:,:,2) + new_Im(:,:,2);
    new_Im(:,:,3) = w_im(:,:,3) + new_Im(:,:,3);
end
end