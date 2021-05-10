function n2 = fb(x, c)
% fb计算两组点之间的平方距离。
% D=fb（X，C）取两个向量矩阵并计算它们之间的平方欧氏距离。两个矩阵必须具有相同的列维度。
% 如果X有M行和N列，而C有L行和N列，则结果有M行和L列。第I，J项是从X的第I行到C的第j行的距离的平方。

[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
if dimx ~= dimc
    error('Data dimension does not match dimension of centres')
end

n2 = (ones(ncentres, 1) * sum((x .^ 2)', 1))' + ...
ones(ndata, 1) * sum((c .^ 2)',1) - ...
2 .* (x * (c'));

if any(any(n2 < 0))
    n2(n2 < 0) = 0;
end
end
