

% Specify the folder where the files are located
folderPath = 'C:\Users\berezinm\Dropbox\Papers\2023 Correlation paper\Pathways\GO pathways\Renamed GO files';

% Specify the Excel file with name mappings
excelFile = 'GO terms all 13383.xlsx';

% Read the Excel file
[~,~,raw] = xlsread(excelFile);

% Get a list of all files in the folder
files = dir(fullfile(folderPath, '*'));

% Iterate over each file in the folder
for i = 1:length(files)
    oldFileName = files(i).name;

    % Skip directories and hidden files
    if files(i).isdir || startsWith(oldFileName, '.')
        continue;
    end

    % Remove 'path_' if it exists in the fileName
    modifiedFileName = strrep(oldFileName, 'path_', '');
    modifiedFileName = strrep(modifiedFileName, '.txt', '');

    % Initialize a flag to track if a match is found
    matchFound = false;

    % Iterate over each mapping in the Excel file
    for j = 1:size(raw, 1)
        excelName = raw{j, 1}; % Name from Excel (first column)

        % Check if the modified file name matches the name in Excel
        if strcmp(modifiedFileName, excelName)
            newNamePart = raw{j, 2}; % New name part from Excel (second column)

            % Full path for old and new file names
            oldFilePath = fullfile(folderPath, oldFileName);
            newFilePath = fullfile(folderPath, [excelName, '_', newNamePart, '.txt']);

            % Rename the file
            movefile(oldFilePath, newFilePath);
            fprintf('Renamed %s to %s\n', oldFileName, [excelName, '_', newNamePart, '.txt']);
            
            % Set the match flag to true
            matchFound = true;
            break; % Exit the loop once a match is found and file is renamed
        end
    end

    % Check if a match was not found and print a message
    if ~matchFound
        fprintf('No corresponding entry in Excel for file: %s, skipping...\n', oldFileName);
    end
end
