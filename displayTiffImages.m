function displayTiffImages()
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
    
    % Calculate the number of rows and columns for subplots
    numCols = min(3, numImages);
    numRows = ceil(numImages / numCols);
    
    % Create a figure
    figure('Name', 'TIFF Images in Folder', 'NumberTitle', 'off');
    
    % Load and display each image
    for i = 1:numImages
        % Read the image
        imgPath = fullfile(folderPath, tifFiles(i).name);
        img = imread(imgPath);
        
        % Create subplot
        subplot(numRows, numCols, i);
        
        % Display the image
        imshow(img);
        title(tifFiles(i).name, 'Interpreter', 'none');
    end
    
    % Adjust the layout
    sgtitle(['TIFF Images in: ' folderPath], 'FontSize', 16, 'Interpreter', 'none');
end

% To run the function, simply call:
% displayTiffImages();