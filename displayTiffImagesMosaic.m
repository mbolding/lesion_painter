function displayTiffImagesMosaic(folderPath)
    % To run the function, you can call it in two ways:
    % displayTiffImagesMosaic();  % This will open a folder selection dialog
    % displayTiffImagesMosaic('C:\path\to\your\tiff\folder');  % This will use the provided folder path
    % displayTiffImagesMosaic('../original_data/Jun_06_2024/M1_TIF')
    
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

    % let the user look at the image for QA
    disp('Press any key to continue...');
    pause('on'); % Enable pausing
    pause;       % Wait for keypress

    % write the mosaic image to disk in the folder with the original TIFs 
    imwrite(mosaicImage, outputFileName, 'tif');

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