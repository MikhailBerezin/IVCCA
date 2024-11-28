% Open a file selection dialog to choose the TSV file
[filename, filepath] = uigetfile('*.tsv', 'Select a TSV File');
if isequal(filename, 0)
    disp('File selection canceled.');
    return;
end

% Full path to the selected file
fullFileName = fullfile(filepath, filename);

% Load the TSV file
data = readtable(fullFileName, 'FileType', 'text', 'Delimiter', '\t');

% Get the total number of rows and calculate rows per file
totalRows = height(data);
numFiles = 20;
rowsPerFile = floor(totalRows / numFiles);

% Split the data into 20 parts and write each to a new file
for i = 1:numFiles
    startRow = (i-1)*rowsPerFile + 1;
    if i == numFiles
        % For the last file, include all remaining rows
        endRow = totalRows;
    else
        endRow = i*rowsPerFile;
    end
    
    % Extract subset of data
    subsetData = data(startRow:endRow, :);
    
    % Create new filename and write to file
    newFilename = fullfile(filepath, sprintf('split_file_%d.tsv', i));
    writetable(subsetData, newFilename, 'FileType', 'text', 'Delimiter', '\t');
end

disp('Files split successfully.');
