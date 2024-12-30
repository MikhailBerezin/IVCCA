function totalGenes = calculateTotalGenesUnique(filePaths)
    % This function calculates the total number of unique genes (M) 
    % from multiple files, each containing a list of gene names.
    % 
    % Inputs:
    % - filePaths: A cell array of file paths, each pointing to a file 
    %   with a list of gene names (one gene per line).
    % 
    % Output:
    % - totalGenes: Total number of unique genes (M).

    % Initialize an empty cell array to store all gene names
    allGenes = {};

    % Loop through each file and read the gene names
    for i = 1:length(filePaths)
        % Read gene names from the file
        fileGenes = readtable(filePaths{i}, 'ReadVariableNames', false);
        
        % Convert to cell array if necessary
        if istable(fileGenes)
            fileGenes = table2cell(fileGenes);
        end
        
        % Concatenate with the existing list of genes
        allGenes = [allGenes; fileGenes];
    end

    % Find the total number of unique genes
    uniqueGenes = unique(allGenes);
    totalGenes = numel(uniqueGenes);

    % Display the result
    fprintf('Total number of unique genes (M): %d\n', totalGenes);
end