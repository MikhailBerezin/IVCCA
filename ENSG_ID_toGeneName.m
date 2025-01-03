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
excelData = readcell(fullExcelPath, 'TextType', 'string'); % Ensure strings are loaded
ensgIDs = string(excelData(:, 1)); % Convert to string array (First column: ENSG IDs)
geneNames = string(excelData(:, 2)); % Convert to string array (Second column: Gene names)

% Read the TSV file
data = readtable(fullTsvPath, 'FileType', 'text', 'Delimiter', '\t', 'TextType', 'string'); % Ensure strings

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
outputExcelFileName = fullfile(tsvFilePath, ['updated_' tsvFileName(1:end-4) '.xlsx']);

writetable(data, outputExcelFileName, 'FileType', 'spreadsheet');

disp(['Updated file saved as: ' outputExcelFileName]);
