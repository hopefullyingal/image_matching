function  hough1(image)
% 入口图像为 BW，出口图像为f


[H,theta,rho] = hough(image);


peaks=houghpeaks(H,50);
hold on
lines=houghlines(image,theta,rho,peaks);
figure,imshow(image,[]),title('Hough Transform Detect Result'),
hold on
for k=1:length(lines) 
    xy=[lines(k).point1;lines(k).point2];
plot(xy(:,1),xy(:,2),'LineWidth',4,'Color','green');
end



% 测试代码
% image = imread('hough.jpg');
% res = hough(image);


