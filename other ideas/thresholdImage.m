function thresholdImage(varargin)
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

    % Create figure and display image
    fig = figure('Name', 'Image Thresholding', 'Position', [100 100 800 600]);
    
    % Display the original grayscale image
    imshow(img);
    hold on;
    
    % Create an empty overlay for the thresholded image
    overlay = cat(3, ones(size(img)), zeros(size(img)), zeros(size(img)));
    overlayHandle = imshow(overlay);
    set(overlayHandle, 'AlphaData', zeros(size(img)));
    
    title('Grayscale Image with Red Threshold Overlay');

    % Create slider
    slider = uicontrol('Style', 'slider', ...
                       'Min', 0, 'Max', 255, 'Value', 128, ...
                       'Position', [300 30 200 20], ...
                       'Callback', @updateThreshold);

    % Create text display for threshold value
    thresholdText = uicontrol('Style', 'text', ...
                              'Position', [520 30 60 20], ...
                              'String', '128');

    % Initial threshold update
    updateThreshold(slider);

    % Callback function for slider
    function updateThreshold(source, ~)
        threshold = round(source.Value);
        thresholdText.String = num2str(threshold);
        thresholdedImg = img > threshold;
        
        % Update the overlay
        alphaData = 0.5 * double(thresholdedImg);
        set(overlayHandle, 'AlphaData', alphaData);
    end
end