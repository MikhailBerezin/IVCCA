

% Berezin Lab 2023
% Generating random pathways from a text file

% Read the genes from the original file
fileID = fopen('your path to txt file.txt', 'r');
geneList = textscan(fileID, '%s');
fclose(fileID);
geneList = geneList{1};  % Convert cell array to a regular array

% Loop to create 100 files
for i = 1:100
    % Randomly select a number of genes between 50 and 200
    numGenes = randi([50, 200]);
    selectedGenes = geneList(randperm(length(geneList), numGenes));

    % Generate a unique file name for each file
    fileName = sprintf('random_selected_genes_%d.txt', i);

    % Write the selected genes to a new file
    fileID = fopen(fileName, 'w');
    fprintf(fileID, '%s\n', selectedGenes{:});
    fclose(fileID);
end