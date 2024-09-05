A set of Matlab scripts to ease infarct lesion segmentation in 9.4T T2 MRI images (hyperintense) that have poor homogeneity.  
### files in this repo
- displayTiffImages.m : not used now
- displayTiffImagesMosaic.m : take the TIFF images output from bruker as individual files and make a mosaic for thresholding 
- findRedPixels.m : finds the area of the segmented lesion. multiply by voxel volume to get the lesion volume approximation
- processAllTiffFolders.m : you can use this to run *displayTiffImagesMosaic* on a folder tree if things are named right
- thresholdROI.m : interactive segmentation for poor homageneity images

## instructions for analyzing one volume
### first run *displayTiffImagesMosaic* on the folder of tifs to make a mosaic image
you can run *processAllTiffFolders.m* on this step instead to make mosaics of lots of volumes if things are organized correctly

```matlab
function displayTiffImagesMosaic(folderPath)
    % To run the function, you can now call it in two ways:
    % displayTiffImagesMosaic();  % This will open a folder selection dialog
    % displayTiffImagesMosaic('C:\path\to\your\tiff\folder');  % This will use the provided folder path
    % displayTiffImagesMosaic('../data/Jun_06_2024/M1_TIF')
    
    % If no folder path is provided, open a folder selection dialog
    if nargin < 1 || isempty(folderPath)
        folderPath = uigetdir(pwd, 'Select folder containing TIFF images');
    
        % Check if a folder was selected
        if folderPath == 0
            disp('No folder selected. Operation cancelled.');
            return;
        end
    end
    
    % Get all TIFF files in the specified folder
    tifFiles = dir(fullfile(folderPath, '*.tif'));
    tifFiles = [tifFiles; dir(fullfile(folderPath, '*.tiff'))];
    
    % Sort the files to ensure consistent order
    [~, order] = sort({tifFiles.name});
    tifFiles = tifFiles(order);
    
    numImages = length(tifFiles);
    
    if numImages == 0
        msgbox('No TIFF images found in the selected folder.', 'No Images', 'warn');
        return;
    end
    
    % Create a cell array to store images and their names
    imageCell = cell(1, numImages);
    imageNames = cell(1, numImages);
    
    % Load and crop each image
    for i = 1:numImages
        imgPath = fullfile(folderPath, tifFiles(i).name);
        img = imread(imgPath);
    
        % Crop the image
        croppedImg = cropWhiteBorder(img);
    
        imageCell{i} = croppedImg;
        imageNames{i} = tifFiles(i).name;
    end
    
    % Create a figure
    fig = figure('Name', 'TIFF Images Mosaic', 'NumberTitle', 'off');
    set(gcf, 'Color', 'k');  % Set figure background to black
    
    % Display images as a mosaic
    % montage(imageCell, 'Size', 'auto', 'ThumbnailSize', []);
    montage(imageCell);
    
    % Capture the figure as an image
    frame = getframe(fig);
    mosaicImage = frame2im(frame);

    % Get the folder name and its parent folder name
    [parentPath, folderName] = fileparts(folderPath);
    [~, parentFolderName] = fileparts(parentPath);

    % Create the output filename with parent and current folder names
    outputFileName = fullfile(folderPath, [parentFolderName '_' folderName '_mosaic.tif']);

    disp('Press any key to continue...');
    pause('on'); % Enable pausing
    pause;       % Wait for keypress

    imwrite(mosaicImage, outputFileName, 'tif');

    % imwrite(mosaicImage, 'mosaic.tif', 'tif');

    % Close the figure
    close(fig);

end

function croppedImg = cropWhiteBorder(img)
    % Convert to grayscale if it's a color image
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end
    
    % Find the bounding box of the non-white area
    thresh = graythresh(grayImg);
    bw = imbinarize(grayImg, thresh);
    stats = regionprops(~bw, 'BoundingBox');
    
    % Get the bounding box
    bbox = stats.BoundingBox;
    
    % Add additional cropping (5 pixels from each side)
    extraCrop = 5;
    bbox(1) = bbox(1) + extraCrop;
    bbox(2) = bbox(2) + extraCrop;
    bbox(3) = bbox(3) - 2*extraCrop;
    bbox(4) = bbox(4) - 2*extraCrop;
    
    % Ensure bbox doesn't exceed image boundaries
    bbox(1) = max(1, bbox(1));
    bbox(2) = max(1, bbox(2));
    bbox(3) = min(size(img, 2) - bbox(1) + 1, bbox(3));
    bbox(4) = min(size(img, 1) - bbox(2) + 1, bbox(4));
    
    % Crop the image
    croppedImg = imcrop(img, bbox);
end
```


### then run *thresholdROI* and draw boxes around the lesions to highlight them


When your moue pointer is a cross you draw an ROI box. when you have a pointer, hit a key (below) or click the mouse to get a cross.

keys:

	q: quit

	u: undo last ROI, one level deep

	d: decrease threshold, grow lesion

	f: shrink lesion

	e: erase with ROI

	s: save the result

```matlab
function thresholdROI(filename)
% thresholdROI('/Users/mbolding/Documents/MATLAB/analysis_for_collaborators/Andrabi_mouse_stroke_August_2024/mosaic_data/Jun_06_2024_M1_TIF_mosaic.tif')

thresholdAdj = 1.5;
drawROI = true; % have the user draw an ROI, is default action
eraseROI = false;

% Check if file exists
if ~exist(filename, 'file')
    error('File does not exist: %s', filename);
end

%% Read the image
img = imread(filename);
% Create a red overlay
redOverlay = img;

% Convert image to grayscale if it's not already
if size(img, 3) == 3
    grayImg = rgb2gray(img);
else
    grayImg = img;
end

% Display the image
imshow(redOverlay);

%% user loop
while 1
    undoRed = redOverlay;
    if drawROI && ~eraseROI
        disp("draw")
        % Let the user draw an ROI
        h = drawrectangle();
        % Create a mask from the ROI
        mask = createMask(h);
    else
        drawROI = true;
    end

    if eraseROI == true
        disp("erase")
        % Let the user draw an ROI
        h = drawrectangle();
        % Create a mask from the ROI
        mask = createMask(h);
        mask = repmat(mask, [1 1 3]);
        redOverlay(logical(mask)) = img(logical(mask));
        eraseROI = false;
    else
        disp("threshold")
        % Determinine a threshold within the ROI
        thresh = graythresh(grayImg(mask)) * thresholdAdj;
        % Apply thresholding inside the ROI
        thresholdedImg = grayImg > (thresh * 255);
        % threshMask = thresholdedImg & mask;
        % Update red overlay. 
        redOverlay(:,:,1) = redOverlay(:,:,1) + uint8(thresholdedImg & mask) * 255;
        redOverlay(:,:,2) = redOverlay(:,:,2) - uint8(thresholdedImg & mask) * 100;
        redOverlay(:,:,3) = redOverlay(:,:,3) - uint8(thresholdedImg & mask) * 100;
        % Ensure values are within 0-255 range
        redOverlay = max(0, min(255, redOverlay));
    end
    % Display the result
    imshow(redOverlay);

    % Wait for user input
    k = waitforbuttonpress;
    if k == 1 % If a key was pressed
        key = get(gcf, 'CurrentCharacter');
        if key == 'q'  % Exit if 'q' is pressed
            break;
        end
        if key == 'u' % undo
            redOverlay = undoRed;
            imshow(redOverlay);
        end
        if key == 'd'  % change threshold, grow lesion
            redOverlay = undoRed;
            thresholdAdj = thresholdAdj * 1.05;
            drawROI = false;
        end
        if key == 'f'  % change threshold, shrink lesion
            redOverlay = undoRed;
            thresholdAdj = thresholdAdj * 0.95;
            drawROI = false;
        end
        if key == 'e'  % erase red from masked area
            eraseROI = true;
        end

        if key == 's'  % save result
            disp("save")
            % Capture the figure as an image
            frame = getframe(gcf);
            saveImage = frame2im(frame);

            % Get the folder name and its parent folder name
            [~, bareFileName] = fileparts(filename);

            % Create the output filename with parent and current folder names
            outputFileName = [bareFileName, '_lesion.tif'];
            imwrite(saveImage, outputFileName, 'tif')
        end

    end
end

disp('done.')
end
```

example segmentation
![image](https://github.com/user-attachments/assets/8046da97-bd16-45ce-90a5-fe7d48ffe251)


### then run *findRedPixels* on the lesion mosaic image to count the red pixels


```java
function findRedPixels(filename)
    % If no filename is provided, open a GUI to select a file
    if nargin < 1 || isempty(filename)
        [filename, pathname] = uigetfile('*.tif', 'Select a TIFF file');
        if isequal(filename, 0) || isequal(pathname, 0)
            disp('File selection cancelled');
            redPixels = [];
            return;
        end
        filename = fullfile(pathname, filename);
    end

    % Read the TIFF file
    try
        img = imread(filename);
    catch
        error('Error reading the file. Make sure it''s a valid TIFF image.');
    end

    % Check if the image is RGB
    if size(img, 3) ~= 3
        error('The image must be an RGB image.');
    end

    % Extract the red channel
    redChannel = img(:,:,1);

    % Find red pixels (where red channel is significantly higher than others)
    greenChannel = img(:,:,2);
    blueChannel = img(:,:,3);
    redPixels = (redChannel > greenChannel + 30) & (redChannel > blueChannel + 30);

    % Remove isolated pixels using morphological operations
    se = strel('disk', 1);
    redPixels = imopen(redPixels, se);
    redPixels = imclose(redPixels, se);

    % Display results
    figure;
    
    subplot(2,2,1);
    imshow(img);
    title('Original Image');

    subplot(2,2,2);
    imshow(redChannel);
    title('Red Channel');

    subplot(2,2,3);
    imshow(redPixels);
    title('Red Pixels');

    subplot(2,2,4);
    maskedImage = img;
    maskedImage(repmat(~redPixels, [1 1 3])) = 0;
    imshow(maskedImage);
    title('Red Pixels Highlighted');

    numRedPixels = sum(redPixels(:));

    % Output
    disp(['Number of red pixels found: ' num2str(numRedPixels)]);
end
```

example output: Number of red pixels found: 15583
![image](https://res.craft.do/user/full/a47030e1-bee0-bde8-3bcf-105f3345ff32/doc/8F9DB22F-50D4-4753-8AD3-B573271A8049/1AD4C4F7-F212-48D4-BC09-FC155E910991_2/gwgIqTJvFkJ3uz3J5pZBNDZhqyBlahDlxlB2R1VxgDkz/Image.png)



### finally multiply the number of pixels by the voxel volume to get the lesion volume. 


determine the voxel volume by loading the DICOM into a DICOM viewer (ITKSnap, OsiriX, MRICron, etc.) or into Matlab. 

To load DICOM files into MATLAB and find the voxel size, you can follow these steps:

### 1. Load DICOM Files


MATLAB offers functions to read DICOM files, such as `dicomread` for reading image data and `dicominfo` for extracting metadata.

```matlab
% Specify the directory containing DICOM files
dicomDir = 'path_to_dicom_directory';

% List all files in the directory (assuming they have .dcm extension)
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

% Load the first DICOM file as an example
filename = fullfile(dicomDir, dicomFiles(1).name);
info = dicominfo(filename);
imageData = dicomread(info);
```


### 2. Access Voxel Size Information


Voxel size information is typically stored in the DICOM metadata. Common field names include `PixelSpacing` and `SliceThickness`.

```matlab
% Retrieve voxel size information from the metadata
pixelSpacing = info.PixelSpacing;  % In-plane pixel spacing (row, column) in mm
sliceThickness = info.SliceThickness;  % Thickness of the slices in mm

% Display the voxel size
voxelSize = [pixelSpacing(1), pixelSpacing(2), sliceThickness];
disp(['Voxel size: ', num2str(voxelSize(1)), ' x ', num2str(voxelSize(2)), ' x ', num2str(voxelSize(3)), ' mm']);

% Display the voxel volume
voxelVolume = prod(voxelSize);  % In cubic millimeters
disp(['Voxel volume: ', num2str(voxelVolume), ' cubic mm']);
```

for our current thinslice T2 protocol... 
- Voxel size: 0.078125 x 0.078125 x 0.5 mm
- Voxel volume: 0.0030518 cubic mm

### Example Code


Below is a complete example that loads all DICOM files in a directory and displays the voxel size for the first file:

```matlab
% Specify the directory containing DICOM files
dicomDir = uigetdir;

% List all DICOM files in the directory
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

% Check if there are any DICOM files in the directory
if isempty(dicomFiles)
    error('No DICOM files found in the specified directory.');
end

% Load the first DICOM file and get metadata
filename = fullfile(dicomDir, dicomFiles(1).name);
info = dicominfo(filename);
imageData = dicomread(info);

% Retrieve voxel size information from the metadata
pixelSpacing = info.PixelSpacing;  % In-plane pixel spacing (row, column) in mm
sliceThickness = info.SliceThickness;  % Thickness of the slices in mm

% Combine to form voxel size
voxelSize = [pixelSpacing(1), pixelSpacing(2), sliceThickness];

% Display the voxel size
fprintf('Voxel size: %.2f x %.2f x %.2f mm\n', voxelSize(1), voxelSize(2), voxelSize(3));
```


