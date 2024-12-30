function hypergeometric_test 
    % This function creates a user interface (UI) to perform a hypergeometric test.
    % The hypergeometric test is used to calculate the statistical significance 
    % of the overlap between two sets of genes, given their total sizes and 
    % the size of the overlap. The UI allows the user to input the relevant 
    % parameters, perform the calculation, and display the resulting p-value.

    % Create the figure window with a title, size, and icon
    fig = uifigure('Position', [100 100 500 300], 'Color', [0.9 0.9 0.9], ...
        'Name', 'Hypergeometric P-value Calculator (Berezin Lab at WashU)', 'icon', 'IVCCA.png');

    % Create labels and edit fields for user inputs
    % Input 1: Total number of genes (M) which is the total number of unique genes
    % in the entire population or "universe" being studied, which may or may not include all genes from both 

    uilabel(fig, 'Position', [30 250 180 22], 'Text', 'Total Genes (M):');
    M_edit = uieditfield(fig, 'numeric', 'Position', [250 250 100 22], 'Value', 12327);

    % Input 2: Number of genes in set A
    uilabel(fig, 'Position', [30 200 180 22], 'Text', 'Genes in Set A:');
    N_human_edit = uieditfield(fig, 'numeric', 'Position', [250 200 100 22], 'Value', 1307);

    % Input 3: Number of genes in set B
    uilabel(fig, 'Position', [30 150 180 22], 'Text', 'Genes in Set B:');
    N_mouse_edit = uieditfield(fig, 'numeric', 'Position', [250 150 100 22], 'Value', 167);

    % Input 4: Number of overlapping genes
    uilabel(fig, 'Position', [30 100 180 22], 'Text', 'Number of Overlapping Genes:');
    overlap_edit = uieditfield(fig, 'numeric', 'Position', [250 100 100 22], 'Value', 35);

    % Create a button to calculate the hypergeometric p-value
    calcButton = uibutton(fig, 'push', 'Position', [200 50 150 40], 'Text', 'Calculate P-value', ...
        'ButtonPushedFcn', @(calcButton,event) calculatePValue(M_edit.Value, N_human_edit.Value, N_mouse_edit.Value, overlap_edit.Value));

    % Create an editable field to display the p-value result
    resultEdit = uieditfield(fig, 'text', 'Position', [200 20 150 22], 'Editable', 'on');

    % Callback function to perform the hypergeometric test and display the result
    function calculatePValue(M, N_human, N_mouse, overlap)
        % Perform the hypergeometric test to calculate the p-value
        % hygecdf is used to compute the cumulative distribution function (CDF)
        % 'upper' option calculates the upper tail probability
        p_value = hygecdf(overlap-1, M, N_human, N_mouse, 'upper');
        
        % Display the p-value in the editable text field
        resultEdit.Value = num2str(p_value);
        
        % Print the p-value to the MATLAB Command Window
        disp(['The hypergeometric p-value is: ', num2str(p_value)]);
    end
end


function totalGenes = calculateTotalGenes(filePaths)
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

