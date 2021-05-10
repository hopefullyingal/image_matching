function [h_change, inliers] = rmy(ref_P, dst_P, n_p, threshold)
% 4点随机抽样一致拟合
% 输入：
% 匹配点来自图像A，一个3xN的矩阵，第三行是1
% 匹配点来自图像B，一个3xN的矩阵，第三行是1
% threshold - 距离阈值
% n_p - 样本数量
% 1. 随机选择点的最小子集
% 2. 假设模型
% 3. 计算错误函数
% 4. 选择与模型一致的点
% 5. 重复假设并验证，循环

n_lin = 0;
f_p = 8; %拟合点数量
for i=1:2000
    rd = randi([1 n_p],1,f_p);      %生成伪随机数
    p_R = ref_P(:,rd);
    p_D = dst_P(:,rd);
    h = getHomographyMatrix(p_R,p_D,f_p);
    r_ref_P = h * ref_P;
    r_ref_P(1,:) = r_ref_P(1,:) ./ r_ref_P(3,:);
    r_ref_P(2,:) = r_ref_P(2,:) ./ r_ref_P(3,:);
    error = (r_ref_P(1,:) - dst_P(1,:)) .^2 + (r_ref_P(2,:) - dst_P(2,:)) .^2;
    n = nnz(error < threshold);           %误差小于阈值的数目

    if(n >= n_p*.95)
        h_change = h;
        inliers = find(error < threshold);
    break;
    elseif(n > n_lin)
        n_lin = n;
        h_change = h;
        inliers = find(error < threshold);
    end 
end
end