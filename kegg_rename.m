% Specify the folder where the files are located
folderPath = 'C:\Users\berezinm\Documents\InterCorrelation\InterCorrelation\Kegg pathways codes'; % Change to your folder path

% Get a list of all files in the folder with '_genes_in_set.txt' suffix
files = dir(fullfile(folderPath, '*_genes_in_set.txt'));

% Iterate over each file in the folder
for i = 1:length(files)
    oldFileName = files(i).name;

    % Remove 'path_' at the beginning and '_genes_in_set.txt' at the end of the file name
%     newFileName = strrep(oldFileName, 'path_', '');
    newFileName = strrep(oldFileName, '_genes_in_set.txt', '.txt');

    % Full path for old and new file names
    oldFilePath = fullfile(folderPath, oldFileName);
    newFilePath = fullfile(folderPath, newFileName);

    % Rename the file
    movefile(oldFilePath, newFilePath);
    fprintf('Renamed %s to %s\n', oldFileName, newFileName);
end
