% Path to your Excel file
excelFilePath = 'GO_molecular_function.xlsx';

% Read the first column from the Excel file
fileNamesToKeep = readtable(excelFilePath, 'Range', 'A:A');
fileNamesToKeep = table2array(fileNamesToKeep);

% Path to your folder
folderPath = 'C:\Users\berezinm\Dropbox\Papers\2023 Correlation paper\Pathways\GO pathways\GO_molecular_function';


% List all .txt files in the folder
filesInFolder = dir(fullfile(folderPath, '*.txt'));
filesInFolder = {filesInFolder.name};

% Strip the .txt extension from the file names
filesInFolderWithoutExt = cellfun(@(x) erase(x, '.txt'), filesInFolder, 'UniformOutput', false);

% Loop through the files and delete the ones not in the Excel list
for i = 1:length(filesInFolder)
    fileNameWithoutExt = filesInFolderWithoutExt{i};
    if ~ismember(fileNameWithoutExt, fileNamesToKeep)
        delete(fullfile(folderPath, filesInFolder{i}));
    end
end
