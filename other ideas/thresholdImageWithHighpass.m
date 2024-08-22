function thresholdImageWithHighpass(varargin)
% thresholdImageWithHighpass('/Users/mbolding/Documents/MATLAB/analysis_for_collaborators/Andrabi_mouse_stroke_August_2024/mosaic_data/Jun_06_2024_M1_TIF_mosaic.tif')
    % Check if an image file is provided as an argument
    if nargin > 0
        imgFile = varargin{1};
    else
        % If no argument, use GUI to select an image file
        [fileName, filePath] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'}, 'Select an image');
        if fileName == 0
            disp('No file selected. Exiting...');
            return;
        end
        imgFile = fullfile(filePath, fileName);
    end

    % Load the image
    img = imread(imgFile);

    % Convert to grayscale if it's not already
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Convert to double for filtering
    img = im2double(img);

    % Create figure and display image
    fig = figure('Name', 'Image Processing', 'Position', [100 100 800 600]);
    
    % Display the original grayscale image
    ax = axes('Position', [0.05 0.3 0.9 0.65]);
    imgHandle = imshow(img);
    hold on;
    
    % Create an empty overlay for the thresholded image
    overlay = cat(3, ones(size(img)), zeros(size(img)), zeros(size(img)));
    overlayHandle = imshow(overlay);
    set(overlayHandle, 'AlphaData', zeros(size(img)));
    
    title('Highpass Filtered Image with Red Threshold Overlay');

    % Create threshold slider
    uicontrol('Style', 'text', 'Position', [50 120 100 20], 'String', 'Threshold:');
    thresholdSlider = uicontrol('Style', 'slider', ...
                       'Min', 0, 'Max', 1, 'Value', 0.5, ...
                       'Position', [150 120 200 20], ...
                       'Callback', @updateImage);

    % Create highpass filter size slider
    uicontrol('Style', 'text', 'Position', [400 120 100 20], 'String', 'Filter Size:');
    filterSizeSlider = uicontrol('Style', 'slider', ...
                       'Min', 3, 'Max', 1000, 'Value', 3, ...
                       'Position', [500 120 200 20], ...
                       'Callback', @updateImage);

    % Create text displays for values
    thresholdText = uicontrol('Style', 'text', 'Position', [360 120 40 20], 'String', '0.5');
    filterSizeText = uicontrol('Style', 'text', 'Position', [710 120 40 20], 'String', '3');

    % Initial image update
    updateImage();

    % Callback function for sliders
    function updateImage(~, ~)
        % Get current slider values
        threshold = thresholdSlider.Value;
        filterSize = round(filterSizeSlider.Value);
        
        % Ensure filter size is odd
        filterSize = filterSize + (mod(filterSize, 2) == 0);
        
        % Update text displays
        thresholdText.String = sprintf('%.2f', threshold);
        filterSizeText.String = num2str(filterSize);
        
        % Apply highpass filter
        h = fspecial('average', [filterSize filterSize]);
        lowpassImg = imfilter(img, h, 'replicate');
        highpassImg = img - lowpassImg;
        
        % Normalize highpass image to [0, 1] range for better visualization
        highpassImg = (highpassImg - min(highpassImg(:))) / (max(highpassImg(:)) - min(highpassImg(:)));
        
        % Update displayed image
        set(imgHandle, 'CData', highpassImg);
        
        % Update threshold overlay
        thresholdedImg = highpassImg > threshold;
        alphaData = 0.5 * double(thresholdedImg);
        set(overlayHandle, 'AlphaData', alphaData);
    end
end