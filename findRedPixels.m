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