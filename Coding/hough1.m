function  hough1(image)
% ���ͼ��Ϊ BW������ͼ��Ϊf


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



% ���Դ���
% image = imread('hough.jpg');
% res = hough(image);


