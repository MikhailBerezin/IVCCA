% Select the TSV file
[tsvFileName, tsvFilePath] = uigetfile('*.tsv', 'Select the TSV File');
if isequal(tsvFileName, 0)
    disp('File selection canceled.');
    return;
end
fullTsvPath = fullfile(tsvFilePath, tsvFileName);

% Select the Excel file containing ENSG IDs and gene names
[excelFileName, excelFilePath] = uigetfile('*.xlsx', 'Select the Excel File');
if isequal(excelFileName, 0)
    disp('File selection canceled.');
    return;
end
fullExcelPath = fullfile(excelFilePath, excelFileName);

% Load the data from the Excel file
excelData = readcell(fullExcelPath);
ensgIDs = excelData(:, 1); % First column: ENSG IDs
geneNames = excelData(:, 2); % Second column: Gene names

% Read the TSV file
data = readtable(fullTsvPath, 'FileType', 'text', 'Delimiter', '\t');

% Replace the ENSG IDs in the first column with gene names
for i = 1:height(data)
    ensgID = data{i, 1}; % Value in the first column
    if iscell(ensgID) % Handle cell arrays
        ensgID = ensgID{1}; % Extract the actual content
    end
    
    % Ensure the extracted ensgID is a char or string for comparison
    ensgID = char(ensgID); % Convert to character array if needed
    
    matchIdx = find(strcmp(ensgIDs, ensgID)); % Find matching ENSG ID in Excel file
    if ~isempty(matchIdx)
        % Replace ENSG ID with the corresponding gene name
        data{i, 1} = geneNames{matchIdx}; % Assign the gene name from Excel
    end
end

% Save the updated TSV file
outputFileName = fullfile(tsvFilePath, ['updated_' tsvFileName]);
writetable(data, outputFileName, 'FileType', 'text', 'Delimiter', '\t');

disp(['Updated file saved as: ' outputFileName]);
