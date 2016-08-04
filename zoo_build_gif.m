clear
ratio = 0.6;
% anat2template
img1 = imread('summary_X_0010032_anat.jpg');
img2 = imread('summary_template.jpg');

% anat2func
img1 = imread('summary_X_0010032_func.jpg');
img2 = imread('summary_X_0010032_anat.jpg');

imgr = imresize (img1,ratio);
alpha = linspace(0,1,3);

%if anat2template
img_all = zeros([size(imgr),1,length(alpha)]);
for aa =1:length(alpha)
    img_all(:,:,1,aa) = imresize(alpha(aa)*img1 + (1-alpha(aa))*img2,ratio);
end
img_all2 = zeros([size(imgr) 1 length(alpha)*2-2]);
img_all2(:,:,:,1:length(alpha)) = img_all;
img_all2(:,:,:,length(alpha)+1:end) = img_all(:,:,:,end-1:-1:2);
imwrite(img_all2/max(img_all2(:)),'test.gif','Quality',0.25,'DelayTime',[0.3 0.15 0.4 0.15]);


%if func2anat
img_all = zeros([size(imgr),length(alpha)]);
for aa =1:length(alpha)
    img_all(:,:,:,aa) = imresize(alpha(aa)*img1 + (1-alpha(aa))*img2,ratio);
end
img_all2 = zeros([size(imgr) length(alpha)*2-2]);
img_all2(:,:,:,1:length(alpha)) = img_all;
img_all2(:,:,:,length(alpha)+1:end) = img_all(:,:,:,end-1:-1:2);
imwrite(img_all2/max(img_all2(:)),'test.gif','Quality',0.25,'DelayTime',[0.3 0.15 0.4 0.15]);



