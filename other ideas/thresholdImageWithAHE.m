function thresholdImageWithAHE(varargin)
% thresholdImageWithAHE('/Users/mbolding/Documents/MATLAB/analysis_for_collaborators/Andrabi_mouse_stroke_August_2024/mosaic_data/Jun_06_2024_M1_TIF_mosaic.tif')
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
    fig = figure('Name', 'Image Processing', 'Position', [100 100 800 600]);
    
    % Display the original grayscale image
    ax = axes('Position', [0.05 0.3 0.9 0.65]);
    imgHandle = imshow(img);
    hold on;
    
    % Create an empty overlay for the thresholded image
    overlay = cat(3, ones(size(img)), zeros(size(img)), zeros(size(img)));
    overlayHandle = imshow(overlay);
    set(overlayHandle, 'AlphaData', zeros(size(img)));
    
    title('AHE Image with Red Threshold Overlay');

    % Create threshold slider
    uicontrol('Style', 'text', 'Position', [50 120 100 20], 'String', 'Threshold:');
    thresholdSlider = uicontrol('Style', 'slider', ...
                       'Min', 0, 'Max', 255, 'Value', 128, ...
                       'Position', [150 120 200 20], ...
                       'Callback', @updateImage);

    % Create AHE tile size slider
    uicontrol('Style', 'text', 'Position', [400 120 100 20], 'String', 'AHE Tile Size:');
    tileSizeSlider = uicontrol('Style', 'slider', ...
                       'Min', 2, 'Max', 100, 'Value', 8, ...
                       'Position', [500 120 200 20], ...
                       'Callback', @updateImage);

    % Create text displays for values
    thresholdText = uicontrol('Style', 'text', 'Position', [360 120 40 20], 'String', '128');
    tileSizeText = uicontrol('Style', 'text', 'Position', [710 120 40 20], 'String', '8');

    % Initial image update
    updateImage();

    % Callback function for sliders
    function updateImage(~, ~)
        % Get current slider values
        threshold = round(thresholdSlider.Value);
        tileSize = round(tileSizeSlider.Value);
        
        % Update text displays
        thresholdText.String = num2str(threshold);
        tileSizeText.String = num2str(tileSize);
        
        % Apply AHE
        aheImg = adapthisteq(img, 'NumTiles', [tileSize tileSize], 'Distribution', 'uniform');
        
        % Update displayed image
        set(imgHandle, 'CData', aheImg);
        
        % Update threshold overlay
        thresholdedImg = aheImg > threshold;
        alphaData = 0.5 * double(thresholdedImg);
        set(overlayHandle, 'AlphaData', alphaData);
    end
end