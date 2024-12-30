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

% Proceed with ENSG ID to Gene Name conversion

% Select the Excel file containing ENSG IDs and gene names
[excelFileName, excelFilePath] = uigetfile('*.xlsx', 'Select the Excel File');
if isequal(excelFileName, 0)
    disp('File selection canceled.');
    return;
end
fullExcelPath = fullfile(excelFilePath, excelFileName);

% Load the data from the Excel file
excelData = readcell(fullExcelPath, 'TextType', 'string'); % Ensure strings are loaded
ensgIDs = string(excelData(:, 1)); % Convert to string array (First column: ENSG IDs)
geneNames = string(excelData(:, 2)); % Convert to string array (Second column: Gene names)

% Replace the ENSG IDs in the first column with gene names
for i = 1:height(data)
    ensgID = string(data{i, 1}); % Ensure ensgID is a string
    
    % Find matching ENSG ID in Excel file
    matchIdx = find(ensgIDs == ensgID); % Use == for string comparison
    if ~isempty(matchIdx)
        if numel(matchIdx) > 1
            warning('Multiple matches found for %s. Using the first match.', ensgID);
            matchIdx = matchIdx(1); % Use the first match
        end
        % Replace ENSG ID with the corresponding gene name
        data{i, 1} = geneNames(matchIdx); % Assign the gene name from Excel
    else
        warning('No match found for ENSG ID: %s. Leaving it unchanged.', ensgID);
    end
end

% Save the updated file in Excel format
outputExcelFileName = fullfile(filepath, ['updated_' filename(1:end-4) '.xlsx']);
writetable(data, outputExcelFileName, 'FileType', 'spreadsheet');

disp(['Updated file saved as: ' outputExcelFileName]);
