function displayTiffImagesMosaic()
    % Open a folder selection dialog
    folderPath = uigetdir(pwd, 'Select folder containing TIFF images');
    
    % Check if a folder was selected
    if folderPath == 0
        disp('No folder selected. Operation cancelled.');
        return;
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
    
    % Load each image
    for i = 1:numImages
        imgPath = fullfile(folderPath, tifFiles(i).name);
        imageCell{i} = imread(imgPath);
        imageNames{i} = tifFiles(i).name;
    end
    
    % Create a figure
    figure('Name', 'TIFF Images Mosaic', 'NumberTitle', 'off');
    
    % Display images as a mosaic
    % montage(imageCell, 'Size', 'auto', 'ThumbnailSize', []);
    montage(imageCell);
    
    % Add title to the mosaic
    title(['TIFF Images in: ' folderPath], 'FontSize', 16, 'Interpreter', 'none');
    
    % Add image names as labels
    ax = gca;
    ax.Visible = 'on';
    ax.YAxis.Visible = 'off';
    ax.XAxis.Visible = 'off';
    
    [rows, cols] = size(ax.Children.Children);
    for i = 1:numImages
        [row, col] = ind2sub([rows, cols], i);
        text(col, row, imageNames{i}, 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'bottom', 'Color', 'white', ...
             'FontSize', 8, 'Interpreter', 'none');
    end
end

% To run the function, simply call:
% displayTiffImagesMosaic();