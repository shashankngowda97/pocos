I = imread('pcos_images/g8.jpg');
I = imresize(I, [227,277]);
#I = imsmooth(I, 'Gaussian');
I_bin = im2bw(I, graythresh(I));
J = histeq(I_bin);
#a = size(J,1);
#b = size(J,2);
#J = double(I(:,:,2:3));
a = size(J,1);
b = size(J,2);
J_reshape = reshape(J, a, b);
[cluster_idx cluster_centers] = kmeans(J_reshape, 3, 'Distance', 'sqeuclidean');
pixel_labels = reshape(cluster_idx, a, 1);
rgb_label = repmat(pixel_labels, [1,1,3]);
segmented_images = cell(1,3);
for k = 1:3
  colors = J;
  colors(rgb_label ~=k) = 0;
  segmented_images{k} = colors;
endfor
s1 = segmented_images{1};
s2 = segmented_images{2};
s3 = segmented_images{3};

i = 3;
if(i==1)
  Seg_BI = im2bw(s1, graythresh(s1));
elseif(i==2)
  Seg_BI = im2bw(s1, graythresh(s2));
else
  Seg_BI = im2bw(s1, graythresh(s3));
endif

[M ne] = bwlabeln(I_bin);
temp = imsmooth(I, 'Gaussian', 2);
BI = im2bw(temp, graythresh(temp));
stats = regionprops(BI, 'Centroid',...
 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
centers = stats.Centroid;
Maj_len = stats.MajorAxisLength;
Min_len = stats.MinorAxisLength;
Orient = stats.Orientation;
diameters = mean([Maj_len Min_len],2);
label = bwlabel(I_bin);

properties = regionprops(label, 'Area', 'Solidity');
density = [properties.Solidity];
#convex_area = [properties.ConvexArea];
area = [properties.Area];
densecond = density > 0.5;

denseMax = max(area(densecond));
I_bin2 = bwareafilt(Seg_BI,[5 1000]);
[m n] = size(I_bin2);
norm = abs(0.1*n);
normr = abs(0.1*m);
I_bin2(:,1:norm) = 0;
I_bin2(:,n-norm:n) = 0;
I_bin2(1:normr,:) = 0;
I_bin2(m-normr:m,:) = 0;

#I_bin2 = imfill(I_bin2, 'holes');
[final_im fol_count] = bwlabeln(I_bin2);
temp_var = imsubtract(I_bin, I_bin2);
temp_var2 = imsubtract(J, temp_var);
figure(1);
subplot(2,2,1), imshow(I); title('Original image');
subplot(2,2,2), imshow(J); title('Histogram equalized image');
subplot(2,2,3), imshow(Seg_BI); title('Segmented binary image');
subplot(2,2,4), imshow(temp_var2); title('follicles image');
#disp('Follicle count from algorithm run :');
#disp(fol_count);
msgbox(sprintf('FOLLICLE COUNT = %d', fol_count));


  
