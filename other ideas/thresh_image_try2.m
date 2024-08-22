function thresholdedImage = thresh_image_try2(filename)
% thresh_image_try2('/Users/mbolding/Documents/MATLAB/analysis_for_collaborators/Andrabi_mouse_stroke_August_2024/mosaic_data/Jun_06_2024_M1_TIF_mosaic.tif')
    % Check if file exists
    if ~exist(filename, 'file')
        error('File does not exist: %s', filename);
    end

    % Read the image
    img = imread(filename);

    % Display the image
    figure;
    imshow(img);
    title('Original Image');

    % Let the user draw an ROI
    h = drawfreehand;
    wait(h);

    % Create a mask from the ROI
    mask = createMask(h);

    % Get the threshold value from the user
    prompt = 'Enter threshold value (0-255): ';
    thresh = input(prompt);

    % Convert image to grayscale if it's not already
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end

    % Apply thresholding inside the ROI
    thresholded = grayImg > thresh;
    result = img;
    for i = 1:3
        channel = result(:,:,i);
        channel(mask) = uint8(thresholded(mask)) * 255;
        result(:,:,i) = channel;
    end

    % Display the result
    figure;
    imshow(result);
    title('Thresholded Image within ROI');

    % Return the result
    % thresholdedImage = result;
end