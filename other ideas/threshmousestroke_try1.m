% Use GUI to select the image file
[filename, pathname] = uigetfile({'*.png;*.jpg;*.tif;*.bmp', 'Image Files (*.png, *.jpg, *.tif, *.bmp)'; ...
                                  '*.*', 'All Files (*.*)'}, ...
                                 'Select the MRI Image');

if isequal(filename, 0) || isequal(pathname, 0)
    disp('User canceled file selection. Exiting...');
    return;
end

% Construct full file path and read the image
fullFilePath = fullfile(pathname, filename);
img = imread(fullFilePath);

% Convert to grayscale if it's not already
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Convert to double for processing
img = im2double(img);

% Display the image and let the user draw a freehand ROI
figure;
imshow(img);
title('Draw a freehand ROI around the area of interest');
h = drawfreehand();
roi_mask = createMask(h);

% Apply the ROI mask to the image
img_roi = img .* roi_mask;

% Apply contrast stretching
img_stretched = imadjust(img_roi);

% Threshold the image to isolate hyperintense regions
threshold = graythresh(img_stretched);
binary_img = imbinarize(img_stretched, threshold * 1.2); % Adjust threshold as needed

% Perform morphological operations to clean up the binary image
se = strel('disk', 2);
binary_img = imopen(binary_img, se);
binary_img = imclose(binary_img, se);

% Remove small objects
binary_img = bwareaopen(binary_img, 50);

% Overlay the segmented regions on the original image
overlay = imoverlay(img, binary_img, [1 0 0]);

% Display results
figure;
subplot(2,2,1); imshow(img); title('Original Image');
subplot(2,2,2); imshow(img_roi); title('ROI');
subplot(2,2,3); imshow(binary_img); title('Segmented Lesions');
subplot(2,2,4); imshow(overlay); title('Overlay');