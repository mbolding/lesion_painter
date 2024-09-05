% Specify the directory containing DICOM files
dicomDir = uigetdir;

% List all DICOM files in the directory
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

% Check if there are any DICOM files in the directory
if isempty(dicomFiles)
    error('No DICOM files found in the specified directory.');
end

% Load the first DICOM file and get metadata
filename = fullfile(dicomDir, dicomFiles(1).name);
info = dicominfo(filename);
imageData = dicomread(info);

% Retrieve voxel size information from the metadata
pixelSpacing = info.PixelSpacing;  % In-plane pixel spacing (row, column) in mm
sliceThickness = info.SliceThickness;  % Thickness of the slices in mm

% Combine to form voxel size
voxelSize = [pixelSpacing(1), pixelSpacing(2), sliceThickness];

% Display the voxel size
fprintf('Voxel size: %.2f x %.2f x %.2f mm\n', voxelSize(1), voxelSize(2), voxelSize(3));

% Display the voxel volume
voxelVolume = prod(voxelSize);  % In cubic millimeters
disp(['Voxel volume: ', num2str(voxelVolume), ' cubic mm']);