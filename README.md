A set of Matlab scripts to ease infarct lesion segmentation in 9.4T T2 MRI images (hyperintense) that have poor homogeneity.  
### main files in this repository
- displayTiffImagesMosaic.m : take the TIFF images output from bruker as individual files and make a mosaic for thresholding 
- findRedPixels.m : finds the area of the segmented lesion. multiply by voxel volume to get the lesion volume approximation
- processAllTiffFolders.m : you can use this to run *displayTiffImagesMosaic* on a folder tree if things are named right
- thresholdROI.m : interactive segmentation for poor homogeneity images

## instructions for analyzing one volume
### first run *displayTiffImagesMosaic.m* on the folder of tifs to make a mosaic image of each volume
you can run *processAllTiffFolders.m* on this step instead to make mosaics of lots of volumes if things are organized correctly. see [below](#TIF-folder-organization). 

### then run *thresholdROI.m* and draw boxes around the lesions on the mosaic volumes to paint them
When your mouse pointer is a cross you can draw an ROI box. When you have a arrow, hit a key (see below) or click the mouse to get a cross.
keys:

	q: quit

	u: undo last ROI, one level deep

	d: "decrease", shrink lesion

	f: "fill more", grow lesion

	e: erase with ROI

	s: save the result, calculate areas, and log the result to log.txt

example segmentation
![image](https://github.com/user-attachments/assets/8046da97-bd16-45ce-90a5-fe7d48ffe251)

example output: Number of red pixels found: 15583
![image](https://res.craft.do/user/full/a47030e1-bee0-bde8-3bcf-105f3345ff32/doc/8F9DB22F-50D4-4753-8AD3-B573271A8049/1AD4C4F7-F212-48D4-BC09-FC155E910991_2/gwgIqTJvFkJ3uz3J5pZBNDZhqyBlahDlxlB2R1VxgDkz/Image.png)

### finally multiply the number of pixels by the voxel volume to get the lesion volume by processing teh log file with *make_results_table.m*. 

## to determine voxel volume
Determine the voxel volume by loading the DICOM into a DICOM viewer (ITKSnap, OsiriX, MRICron, etc.) or into Matlab. 

To load DICOM files into MATLAB and find the voxel size, you can follow these steps:

### 1. Load DICOM Files
MATLAB offers functions to read DICOM files, such as `dicomread` for reading image data and `dicominfo` for extracting metadata.

```matlab
% Specify the directory containing DICOM files
dicomDir = 'path_to_dicom_directory';

% List all files in the directory (assuming they have .dcm extension)
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

% Load the first DICOM file as an example
filename = fullfile(dicomDir, dicomFiles(1).name);
info = dicominfo(filename);
imageData = dicomread(info);
```


### 2. Access Voxel Size Information
Voxel size information is typically stored in the DICOM metadata. Common field names include `PixelSpacing` and `SliceThickness`.

```matlab
% Retrieve voxel size information from the metadata
pixelSpacing = info.PixelSpacing;  % In-plane pixel spacing (row, column) in mm
sliceThickness = info.SliceThickness;  % Thickness of the slices in mm

% Display the voxel size
voxelSize = [pixelSpacing(1), pixelSpacing(2), sliceThickness];
disp(['Voxel size: ', num2str(voxelSize(1)), ' x ', num2str(voxelSize(2)), ' x ', num2str(voxelSize(3)), ' mm']);

% Display the voxel volume
voxelVolume = prod(voxelSize);  % In cubic millimeters
disp(['Voxel volume: ', num2str(voxelVolume), ' cubic mm']);
```

for our current thinslice T2 protocol... 
- Voxel size: 0.078125 x 0.078125 x 0.5 mm
- Voxel volume: 0.0030518 cubic mm

### Example Code
Below is a complete example that loads all DICOM files in a directory and displays the voxel size for the first file:

```matlab
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
```

## TIF folder organization
data oraganization for the TIFs is a top level dir, then dir by date, then the sample dirs with the TIFs  e.g.: 
```
./trimmed_data/May_24_2024:
M1_TIF			M3_TIF			MRI_Notes.jpeg
M2_TIF			M5_TIF			May_24_2024_Andrabi.zip

./trimmed_data/May_24_2024/M1_TIF:
4_T2_RARE_thinslice_Im01.tif	4_T2_RARE_thinslice_Im07.tif	4_T2_RARE_thinslice_Im13.tif	4_T2_RARE_thinslice_Im19.tif
4_T2_RARE_thinslice_Im02.tif	4_T2_RARE_thinslice_Im08.tif	4_T2_RARE_thinslice_Im14.tif	4_T2_RARE_thinslice_Im20.tif
4_T2_RARE_thinslice_Im03.tif	4_T2_RARE_thinslice_Im09.tif	4_T2_RARE_thinslice_Im15.tif	4_T2_RARE_thinslice_Im21.tif
4_T2_RARE_thinslice_Im04.tif	4_T2_RARE_thinslice_Im10.tif	4_T2_RARE_thinslice_Im16.tif
4_T2_RARE_thinslice_Im05.tif	4_T2_RARE_thinslice_Im11.tif	4_T2_RARE_thinslice_Im17.tif
4_T2_RARE_thinslice_Im06.tif	4_T2_RARE_thinslice_Im12.tif	4_T2_RARE_thinslice_Im18.tif

./trimmed_data/May_24_2024/M2_TIF:
4_T2_RARE_thinslice_Im01.tif	4_T2_RARE_thinslice_Im07.tif	4_T2_RARE_thinslice_Im13.tif	4_T2_RARE_thinslice_Im19.tif...

...

./trimmed_data/May_30_2024:
IMG_1267.JPG		M1_TIF			M3_TIF			May_30_2024_Andrabi.zip

./trimmed_data/May_30_2024/M1_TIF:
4_T2_RARE_thinslice_Im01.tif	4_T2_RARE_thinslice_Im07.tif	4_T2_RARE_thinslice_Im13.tif	4_T2_RARE_thinslice_Im19.tif
4_T2_RARE_thinslice_Im02.tif	4_T2_RARE_thinslice_Im08.tif	4_T2_RARE_thinslice_Im14.tif	4_T2_RARE_thinslice_Im20.tif
4_T2_RARE_thinslice_Im03.tif	4_T2_RARE_thinslice_Im09.tif	4_T2_RARE_thinslice_Im15.tif	4_T2_RARE_thinslice_Im21.tif
4_T2_RARE_thinslice_Im04.tif	4_T2_RARE_thinslice_Im10.tif	4_T2_RARE_thinslice_Im16.tif
4_T2_RARE_thinslice_Im05.tif	4_T2_RARE_thinslice_Im11.tif	4_T2_RARE_thinslice_Im17.tif
4_T2_RARE_thinslice_Im06.tif	4_T2_RARE_thinslice_Im12.tif	4_T2_RARE_thinslice_Im18.tif

./trimmed_data/May_30_2024/M3_TIF:
4_T2_RARE_thinslice_Im01.tif	4_T2_RARE_thinslice_Im07.tif	4_T2_RARE_thinslice_Im13.tif	4_T2_RARE_thinslice_Im19.tif
4_T2_RARE_thinslice_Im02.tif	4_T2_RARE_thinslice_Im08.tif	4_T2_RARE_thinslice_Im14.tif...	

...


```


