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