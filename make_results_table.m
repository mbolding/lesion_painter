% Read the contents of the text file into a string
filename = 'log.txt'; % Replace with your actual file name
fileContent = fileread(filename);

% Define the regular expression to extract the date, mouse number, and red pixel count
pattern = '(?<Date>[A-Za-z]{3}_\d{2}_\d{4})_(?<Mouse>M\d)_TIF_mosaic_lesion\.tif: (?<Pixels>\d+) red pixels found';

% Use the 'regexp' function to match the pattern in the file content
matches = regexp(fileContent, pattern, 'names');

% Initialize cell arrays to store the extracted data
dates = {matches.Date}';
mice = {matches.Mouse}';
pixels = str2double({matches.Pixels}');

% Calculate the lesion volume
voxelVolume = 0.0030518; % Volume of one voxel in mm^3
volumes = pixels * voxelVolume;

% Round the lesion volumes to 2 decimal places
volumes = round(volumes, 2);

% Create a table to store the extracted data
T = table(dates, mice, pixels, volumes, 'VariableNames', {'Date', 'Mouse', 'SegPixels', 'LesionVolume_mm3'});

% Display the table
disp(T);

% Optionally, save the table to a file (e.g., CSV)
writetable(T, 'results.csv');