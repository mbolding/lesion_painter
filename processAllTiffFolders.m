function processAllTiffFolders(mainDataFolder)
    % If no main data folder is provided, open a folder selection dialog
    if nargin < 1 || isempty(mainDataFolder)
        mainDataFolder = uigetdir(pwd, 'Select the main data folder');
        if mainDataFolder == 0
            disp('No folder selected. Operation cancelled.');
            return;
        end
    end

    % Get all date folders
    dateFolders = dir(fullfile(mainDataFolder, '*'));
    dateFolders = dateFolders([dateFolders.isdir]);  % Keep only directories
    dateFolders = dateFolders(~ismember({dateFolders.name}, {'.', '..'}));  % Remove . and ..

    % Process each date folder
    for i = 1:length(dateFolders)
        dateFolder = fullfile(mainDataFolder, dateFolders(i).name);
        
        % Get all M*_TIF folders
        tifFolders = dir(fullfile(dateFolder, 'M*_TIF'));
        tifFolders = tifFolders([tifFolders.isdir]);  % Keep only directories

        % Process each M*_TIF folder
        for j = 1:length(tifFolders)
            tifFolder = fullfile(dateFolder, tifFolders(j).name);
            disp(['Processing folder: ', tifFolder]);
            
            % Call displayTiffImagesMosaic for this folder
            displayTiffImagesMosaic(tifFolder);
        end
    end

    disp('All folders processed.');
end