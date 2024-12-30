
% Berezin Lab Washington University

% Description
% The TwoSetCorrTool function opens an interactive graphical user interface (GUI) designed for analyzing correlations between two datasets (e.g., gene expression data from two organs). The GUI allows users to load datasets, compute pairwise correlations, sort results, visualize correlations as a heatmap, and save results to an Excel file.
% 
% Features
% Load Data A and Data B: Import two datasets in CSV or Excel format for analysis.
% Correlate: Compute pairwise Pearson correlation coefficients between the datasets.
% Sort Correlation: Sort correlations based on the sum or average of absolute values for prioritizing key relationships.
% Graph Correlations: Display the correlation matrix as a heatmap for visual interpretation.
% Save to Excel: Export correlation results to an Excel file for further analysis.
% PCA: Perform Principal Component Analysis (PCA) on the loaded datasets.
% 
% Usage
% Launch the GUI: Call twoPathwaysCorr in the MATLAB command window to open the interface.
% Load Datasets: Click Load Data A and Load Data B buttons to import datasets. Data should be in tabular format with gene names as column headers.
% Perform Correlation Analysis: Click Correlate to compute pairwise correlations between the datasets.
% Sort Correlation Results: Click Sort Correlation to reorder genes based on their correlation strength.
% Visualize Results: Click Graph Correlations to generate a heatmap of the correlation matrix.
% Save Results: Click Save to Excel to export the correlation table to an Excel file for further use.
% Perform PCA: Click PCA to conduct a Principal Component Analysis on the datasets.
% 

% % Launch the GUI

% Load two datasets (dataA.csv and dataB.csv or dataA.xlsx and dataB.xlsx ) using the Load Data A and Load Data B buttons.
% Click Correlate to compute correlations.
% Click Sort Correlation to prioritize genes with the strongest relationships.
% Generate a heatmap of the sorted correlations by clicking Graph Correlations.
% Save the correlation results to results.xlsx using the Save to Excel button.


function TwoSetCorrTool()




    % Create the main GUI window
    fig = uifigure('Name', 'Two Set Gene Correlation Analysis (Berezin Lab)', 'Position', [100, 100, 850, 600], 'Icon', "IVCCA.png");

    % Add buttons
    btnLoadDataA = uibutton(fig, 'push', 'Text', 'Load Data A', 'Position', [50, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) loadDataA());
    btnLoadDataB = uibutton(fig, 'push', 'Text', 'Load Data B', 'Position', [160, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) loadDataB());
    btnCorrelate = uibutton(fig, 'push', 'Text', 'Correlate', 'Position', [270, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) correlateData());
    btnSortCorrelation = uibutton(fig, 'push', 'Text', 'Sort Correlation', 'Position', [380, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) sortCorrelation());
    btnGraph = uibutton(fig, 'push', 'Text', 'Graph Correlations', 'Position', [490, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) graphCorrelations());
    btnSaveExcel = uibutton(fig, 'push', 'Text', 'Save to Excel', 'Position', [600, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) saveToExcel());
    btnSavePCA = uibutton(fig, 'push', 'Text', 'PCA', 'Position', [710, 550, 100, 22], 'ButtonPushedFcn', @(btn,event) pca3());
   
    persistent dataA dataB geneNamesA geneNamesB 
    % Labels for the tables
    labelDataA = uilabel(fig, 'Text', 'Data A: 0 x 0', 'Position', [50, 510, 300, 20]);
    labelDataB = uilabel(fig, 'Text', 'Data B: 0 x 0', 'Position', [450, 510, 300, 20]);
    labelCorrelation = uilabel(fig, 'Text', 'Correlation: 0 x 0', 'Position', [50, 260, 700, 20]);

    % Add tables to display the data
    tableDataA = uitable(fig, 'Position', [50, 300, 300, 200]);
    tableDataB = uitable(fig, 'Position', [450, 300, 300, 200]);
    tableCorrelation = uitable(fig, 'Position', [50, 50, 700, 200]);

    % Variables to store data
    dataA = [];
    dataB = [];
    geneNamesA = [];
    geneNamesB = [];
    sortedVariableNames = [];  % To store sorted variable names globally

    % Function to load Data A
    function loadDataA()
        [file, path] = uigetfile('*.xlsx', '*.csv');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            fullPath = fullfile(path, file);
            tbl = readtable(fullPath);
            dataA = table2array(tbl(:, 2:end));
            geneNamesA = tbl.Properties.VariableNames(2:end);
            tableDataA.Data = dataA;
            tableDataA.ColumnName = geneNamesA;
            labelDataA.Text = sprintf('Data A: %d x %d', size(dataA, 1), size(dataA, 2));
        end
    end

    % Function to load Data B
    function loadDataB()
        [file, path] = uigetfile('*.xlsx','*.csv');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            fullPath = fullfile(path, file);
            tbl = readtable(fullPath);
            dataB = table2array(tbl(:, 2:end));
            geneNamesB = tbl.Properties.VariableNames(2:end);
            tableDataB.Data = dataB;
            tableDataB.ColumnName = geneNamesB;
            labelDataB.Text = sprintf('Data B: %d x %d', size(dataB, 1), size(dataB, 2));
        end
    end
  
    function correlateData()
   
    if isempty(dataA) || isempty(dataB)
        uialert(fig, 'Load both Data A and Data B before correlating.', 'Data Needed');
        return;
    end
    correlationMatrix = zeros(size(dataA, 2), size(dataB, 2));
    for i = 1:size(dataA, 2)
        for j = 1:size(dataB, 2)
            correlationMatrix(i, j) = corr(dataA(:, i), dataB(:, j), 'Rows', 'complete');
        end
    end
    correlationTable = array2table(correlationMatrix, 'RowNames', geneNamesA, 'VariableNames', geneNamesB);
    tableCorrelation.Data = correlationTable;
    labelCorrelation.Text = sprintf('Correlation: %d x %d', size(correlationMatrix, 1), size(correlationMatrix, 2));

    
end

function sortCorrelation()

    if isempty(tableCorrelation.Data)
        uialert(fig, 'Correlate data before sorting.', 'Correlation Data Needed');
        return;
    end
    correlationMatrix = table2array(tableCorrelation.Data);
    geneNamesA = tableCorrelation.RowName;  % Row names are stored and accessible
    geneNamesB = tableCorrelation.ColumnName;  % Assume you stored column names at data setup

    % Sum of absolute correlations for each gene in dataset A
    sumAbsCorrelations = sum(abs(correlationMatrix), 2);  % Sum across columns for each row
    [~, sortedIndicesA] = sort(sumAbsCorrelations, 'descend');
    
    % Sorting rows based on A's correlation strength to B
    sortedCorrelations = correlationMatrix(sortedIndicesA, :);
    sortedVariableNames = geneNamesA(sortedIndicesA);  % Adjusted to use the stored row names

    % Average of absolute correlations for each gene in dataset B
    avgAbsCorrelationsB = mean(abs(sortedCorrelations), 1);  % Mean across rows for each column
    [~, sortedIndicesB] = sort(avgAbsCorrelationsB, 'descend');

    % Sorting columns based on B's average correlation strength
    sortedCorrelations = sortedCorrelations(:, sortedIndicesB);
    sortedVariableNamesB = geneNamesB(sortedIndicesB);

    sortedCorrelationTable = array2table(sortedCorrelations, 'RowNames', sortedVariableNames, 'VariableNames', sortedVariableNamesB);
    tableCorrelation.Data = sortedCorrelationTable;
    labelCorrelation.Text = sprintf('Sorted Correlation: %d x %d', size(sortedCorrelations, 1), size(sortedCorrelations, 2));
end

function graphCorrelations()
    if isempty(tableCorrelation.Data)
        uialert(fig, 'No correlation data to graph.', 'Graph Error');
        return;
    end
 
    % Assuming the data in tableCorrelation is up-to-date with the sorted correlations
    correlationMatrix = table2array(tableCorrelation.Data);

       % Convert all numbers to absolute values
    correlationMatrix = abs(correlationMatrix);
    geneNamesA = tableCorrelation.RowName;  % Row names (genes from A)
    geneNamesB = tableCorrelation.ColumnName;  % Column names (genes from B)
    
    % Create a new figure for the heatmap
    figure;
%     h = heatmap(geneNamesB, geneNamesA, correlationMatrix);
     h = imagesc(correlationMatrix);

    
    % Additional customization
%     h.Title = 'Correlation Heatmap';
%     h.XLabel = 'Gene Set B';
%     h.YLabel = 'Gene Set A';
%     h.Colormap = parula;  % Choose a colormap that fits the data well, 'parula' is default
%     h.ColorScaling = 'scaledrows';  % Scales the colors row-wise

colorbar; 
    cm = jet(256); 
    cm(1,:) = [0.5 0.5 0.5]; % Change the first color (for zero values) to grey
    colormap(cm); % Apply the modified colormap

    title('Sorted Correlation Heatmap');
    xticks(1:length(geneNamesB));
    yticks(1:length(geneNamesA));
    xticklabels(geneNamesB);
    yticklabels(geneNamesA);

    % Adjust font size for better visibility if needed
%     h.FontSize = 10;
end


function saveToExcel()
    if isempty(tableCorrelation.Data)
        uialert(fig, 'No correlation data to save.', 'Save Error');
        return;
    end
    % Assuming the correlation data is stored in a table as previously defined
    correlationTable = tableCorrelation.Data;
    [file, path] = uiputfile('*.xlsx', 'Save File');
    if isequal(file, 0)
        disp('User selected Cancel');
    else
        fullPath = fullfile(path, file);
        writetable(correlationTable, fullPath, 'WriteRowNames', true);
        disp(['Data saved to ', fullPath]);
    end
end
 
end
