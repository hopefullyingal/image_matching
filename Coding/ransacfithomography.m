function [hh, inliers] = ransacfithomography(ref_P, dst_P, npoints, threshold)
ninlier = 0;
fpoints = 8;
for i=1:2000
    rd = randi([1 npoints],1,fpoints);
    pR = ref_P(:,rd);
    pD = dst_P(:,rd);
    h = getHomographyMatrix(pR,pD,fpoints);
    rref_P = h*ref_P;
    rref_P(1,:) = rref_P(1,:)./rref_P(3,:);
    rref_P(2,:) = rref_P(2,:)./rref_P(3,:);
    error = (rref_P(1,:) - dst_P(1,:)).^2 + (rref_P(2,:) - dst_P(2,:)).^2;
    n = nnz(error<threshold);
    if(n >= npoints*.95)
        hh=h;
        inliers = find(error<threshold);
        pause();
        break;
    elseif(n>ninlier)
        ninlier = n;
        hh=h;
        inliers = find(error<threshold);
    end
end
