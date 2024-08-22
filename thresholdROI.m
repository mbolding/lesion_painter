function thresholdROI(filename)
% thresholdROI('/Users/mbolding/Documents/MATLAB/analysis_for_collaborators/Andrabi_mouse_stroke_August_2024/mosaic_data/Jun_06_2024_M1_TIF_mosaic.tif')

thresholdAdj = 1.5;
drawROI = true;

% Check if file exists
if ~exist(filename, 'file')
    error('File does not exist: %s', filename);
end

% Read the image
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
imshow(grayImg);

while 1
    undoRed = redOverlay;
    if drawROI
        % Let the user draw an ROI
        h = drawrectangle();

        % Create a mask from the ROI
        mask = createMask(h);

        % Apply method for thresholding within the ROI

    else
        drawROI = true;
    end
    roiPixels = grayImg(mask);
    thresh = graythresh(roiPixels) * thresholdAdj;

    % Apply thresholding inside the ROI
    thresholded = grayImg > (thresh * 255);

    % Update red overlay 
    redOverlay(:,:,1) = redOverlay(:,:,1) + uint8(thresholded & mask) * 255;
    redOverlay(:,:,2) = redOverlay(:,:,2) - uint8(thresholded & mask) * 100;
    redOverlay(:,:,3) = redOverlay(:,:,3) - uint8(thresholded & mask) * 100;

    % Ensure values are within 0-255 range
    redOverlay = max(0, min(255, redOverlay));

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
        if key == 'f'  % undo
            redOverlay = undoRed;
            thresholdAdj = thresholdAdj * 1.05
            drawROI = false;
        end
        if key == 'd'  % undo
            redOverlay = undoRed;
            thresholdAdj = thresholdAdj * 0.95
            drawROI = false;
        end

    end
end

disp('done.')
end