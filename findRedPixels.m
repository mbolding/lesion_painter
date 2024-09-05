function findRedPixels(filename)
% findRedPixels - Finds and highlights red pixels in an RGB TIFF image.
%
% Syntax:
%   findRedPixels
%   findRedPixels(filename)
%
% Description:
%   This function reads an RGB TIFF image, identifies pixels where the
%   red channel is significantly higher than the green and blue channels,
%   and highlights those red pixels. The function also displays the
%   original image, the red channel, the detected red pixels, and an
%   image with the red pixels highlighted.
%
%   If no filename is provided as an argument, a GUI will open allowing
%   you to select a TIFF file. The function then counts the number of
%   red pixels found and appends this information along with the filename
%   to a log file named 'log.txt'.
%
% Input Arguments:
%   filename - (Optional) A string specifying the path to a TIFF image file.
%
% Example:
%   findRedPixels('sample_image.tif');
%
%   % To select a file via GUI:
%   findRedPixels;
%
% Output:
%   The function displays several figures showing the original image, the
%   red channel, the detected red pixels, and the red pixels highlighted
%   in the original image. It also appends the filename and the number of
%   detected red pixels to 'log.txt'.
%
% Notes:
%   - The function assumes that the input image is an RGB image.
%   - The log file 'log.txt' is created in the current working directory if
%     it doesn't already exist.
%   - The function uses morphological operations to clean up the detected
%     red pixels by removing noise and small, isolated regions.
%
% test case: findRedPixels('../mosaic_data/Jun_06_2024_M1_TIF_mosaic_lesion.tif')


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

    % Append the result to log.txt so we don't have to cut and paste so
    % much.
    logFilename = 'log.txt';
    fid = fopen(logFilename, 'a');  % Open log.txt in append mode
    if fid == -1
        error('Cannot open log.txt for writing.');
    end
    fprintf(fid, '%s: %d red pixels found\n', filename, numRedPixels);
    fclose(fid);  % Close the file

end