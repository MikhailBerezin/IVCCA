% Specify the folder where the files are located
folderPath = 'C:\Users\berezinm\Dropbox\Papers\2023 Correlation paper\Pathways\GO pathways\Renamed GO files'; % Change this to your folder path

% % Specify the Excel file with name mappings
% excelFile = 'Kegg terms 340.xlsx'; % Change this to your Excel file path

% Get a list of all files in the folder with '_genes_in_set.txt' suffix
files = dir(fullfile(folderPath, '*_genes_in_set.txt'));

% Iterate over each file in the folder
for i = 1:length(files)
    oldFileName = files(i).name;
    % Remove the trailing '_genes_in_set.txt' from the file name
    newFileName = strrep(oldFileName, '_genes_in_set.txt', '');

    % Full path for old and new file names
    oldFilePath = fullfile(folderPath, oldFileName);
    newFilePath = fullfile(folderPath, newFileName);

    % Rename the file
    movefile(oldFilePath, newFilePath);
    fprintf('Renamed %s to %s\n', oldFileName, newFileName);
end
% Specify the folder where the files are located
folderPath = 'C:\Users\berezinm\Dropbox\Papers\2023 Correlation paper\Pathways\GO pathways\Renamed GO files'; % Change this to your folder path

% Specify the Excel file with name mappings
excelFile = 'GO terms 13200.xlsx'; % Change this to your Excel file path

% Read the Excel file
[~,~,raw] = xlsread(excelFile);

% Get a list of all files in the folder (after removing '_genes_in_set.txt')
files = dir(fullfile(folderPath, '*'));

% Iterate over each file in the folder
for i = 1:length(files)
    oldFileName = files(i).name;

    % Skip directories and hidden files
    if files(i).isdir || startsWith(oldFileName, '.')
        continue;
    end

    % Iterate over each mapping in the Excel file
    for j = 1:size(raw, 1)
        excelName = raw{j, 1}; % Name from Excel (first column)

        % Check if the file name matches the name in Excel
        if strcmp(oldFileName, excelName)
            newNamePart = raw{j, 2}; % New name part from Excel (second column)

            % Remove 'path_' if it exists in the excelName
            modifiedExcelName = strrep(excelName, 'path_', '');

            % Full path for old and new file names
            oldFilePath = fullfile(folderPath, oldFileName);
            newFilePath = fullfile(folderPath, [modifiedExcelName, '_', newNamePart, '.txt']);

            % Rename the file
            movefile(oldFilePath, newFilePath);
            fprintf('Renamed %s to %s\n', oldFileName, [modifiedExcelName, '_', newNamePart, '.txt']);
            break; % Exit the loop once a match is found and file is renamed
        end
    end
end

