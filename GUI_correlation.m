function GUI_correlation
% Mikhail Berezin 2023
f = uifigure('Name', 'IVCCA: Inter-Variability Cross Correlation Analysis (Berezin Lab)', 'Position', [200 200 700 450], 'Icon','Corr_icon.png');  % adjusted width
close all
% f.WindowStyle = 'normal';
% uifigureOnTop (f, true) 

% Create the grid layout
grid = uigridlayout(f, [5 2], 'ColumnWidth', {'1x', '0.2x'}, 'RowHeight', {'1x', '1x', '1x', '1x', '1x'});  % now 4x2 grid, second column smaller

% Create the uitable
data = uitable(grid, 'ColumnEditable', true);
data.Layout.Row = [1 14]; % Spans across all rows
data.Layout.Column = 1; % Occupies the first column

% Create the "Load Data" button
load_button = uibutton(grid, 'push', 'Text', 'Load Data', 'ButtonPushedFcn', {@load_data_callback, f});
load_button.Layout.Row = 1; % Position for "Load Data" button
load_button.Layout.Column = 2; 
load_button.Tooltip = 'load the excel or csv data'; 

% Create the "Calculate Correlations" button
calculate_button = uibutton(grid, 'push', 'Text', 'Correlation', 'ButtonPushedFcn', {@calculate_correlations_callback, f});
calculate_button.Layout.Row = 2; % Position for "Calculate Correlations" button
calculate_button.Layout.Column = 2;
calculate_button.Tooltip = 'Calculate the correlation matrix';  % Adding tooltip
calculate_button.Enable = 'off';

% Create the "Sort" button
sort_button = uibutton(grid, 'push', 'Text', 'Sort', 'ButtonPushedFcn', {@sort_callback, f});
sort_button.Layout.Row = 3; % Position for "Sort" button
sort_button.Layout.Column = 2;
sort_button.Tooltip = 'Sort the correlation matrix with the highest first';  % Adding tooltip
sort_button.Enable = 'off'; % Initially disabled

% Create the "SortedGraph" button
graph_button = uibutton(grid, 'push', 'Text', 'Sorted Graph', 'ButtonPushedFcn', {@graph_callback, f});
graph_button.Layout.Row = 4; % Position for "SortedGraph" button
graph_button.Layout.Column = 2;
graph_button.Tooltip = 'Graph the sorted correlation matrix';  % Adding tooltip
graph_button.Enable = 'off'; % Initially disabled

% Create the "Elbow / Silhouette Curves" button
elbow_button = uibutton(grid, 'push', 'Text', 'Elbow/Silhouette', 'ButtonPushedFcn', {@elbow_curve_callback, f});
elbow_button.Layout.Row = 5; % Position for "Elbow Curve" button
elbow_button.Layout.Column = 2;
elbow_button.Tooltip = 'Determine optimal number of clusters';  % Adding tooltip
elbow_button.Enable = 'off'; % Initially disabled

% Create the "Dendrogram" button
cluster_button = uibutton(grid, 'push', 'Text', 'Dendrogram', 'ButtonPushedFcn', {@cluster_callback, f});
cluster_button.Layout.Row = 6; % Position for "Cluster" button
cluster_button.Layout.Column = 2;
cluster_button.Tooltip = 'Cluster the correlation matrix with a dendrogram';  % Adding tooltip
cluster_button.Enable = 'off'; % Initially disabled


% Create the "Dynamic Tree Cut" button
dynamic_tree_button = uibutton(grid, 'push', 'Text', 'Dynamic Tree Cut', 'ButtonPushedFcn', {@dynamic_tree_cut_callback, f});
dynamic_tree_button.Layout.Row = 7; % Position for "Dynamic Tree Cut" button
dynamic_tree_button.Layout.Column = 2;
dynamic_tree_button.Tooltip = 'Perform Dynamic Tree Cutting on the correlation matrix';  % Adding tooltip
dynamic_tree_button.Enable = 'off'; % Initially disabled

% Create the "tsne correlations" button
tsne_button = uibutton(grid, 'push', 'Text', 't-SNE', 'ButtonPushedFcn', @tsne3);
tsne_button.Layout.Row = 8; % Position for "Calculate tsne" button
tsne_button.Layout.Column = 2;
tsne_button.Tooltip = 'Calculate t-SNE scatter plot';  % Adding tooltip
tsne_button.Enable = 'off';


% Create the "Single Pathway" button
sort_path_button = uibutton(grid, 'push', 'Text', 'Single Pathway', 'ButtonPushedFcn', {@sort_path_callback, f});
sort_path_button.Layout.Row = 9; % Position for "SinglePathway" button
sort_path_button.Layout.Column = 2;
sort_path_button.Tooltip = 'Sort the correlation matrix for a selected pathway';  % Adding tooltip
sort_path_button.Enable = 'off'; % Initially disabled

% Create the "Multiple Pathways" button
sort_mpath_button = uibutton(grid, 'push', 'Text', 'Multi Pathways', 'ButtonPushedFcn', {@sort_mpath_callback, f});
sort_mpath_button.Layout.Row = 10; % Position for "Mutliple Pathways" button
sort_mpath_button.Layout.Column = 2;
sort_mpath_button.Tooltip = 'Sort multiple pathways based on the correlation values of their members';  % Adding tooltip
sort_mpath_button.Enable = 'off'; % Initially disabled

% Create the "Single to Group Correlation" button
single_to_group_button = uibutton(grid, 'push', 'Text', 'Gene to Genes', ...
                                  'ButtonPushedFcn', {@single_to_group_correlation_callback, f});
single_to_group_button.Layout.Row = 11; % Choose an appropriate row
single_to_group_button.Layout.Column = 2;
single_to_group_button.Tooltip = 'Calculate correlation of a single gene to a group of genes';
single_to_group_button.Enable = 'off'; % Initially disabled

% Create the "Single to Pathway Correlation" button
single_to_path_button = uibutton(grid, 'push', 'Text', 'Gene to Pathway', ...
                                  'ButtonPushedFcn', {@single_to_pathway_correlation_callback, f});
single_to_path_button.Layout.Row = 12; 
single_to_path_button.Layout.Column = 2;
single_to_path_button.Tooltip = 'Calculate the correlation of a single gene to a pathway';
single_to_path_button.Enable = 'off'; 

% Create the "Compare pathways" button
compare_paths_button = uibutton(grid, 'push', 'Text', 'Compare Pathways', 'ButtonPushedFcn', {@calculate_pathways_correlation_callback, f});
compare_paths_button.Layout.Row = 13; % Position for "Compare pathways" button
compare_paths_button.Layout.Column = 2;
compare_paths_button.Tooltip = 'Calculate the correlation betweeen two pathways';  % Adding tooltip
compare_paths_button.Enable = 'off';

% Create the "Network analysis" button
network_button = uibutton(grid, 'push', 'Text', 'Network analysis', 'ButtonPushedFcn', {@calculate_network_callback, f});
network_button.Layout.Row = 14; % Position for "Network" button
network_button.Layout.Column = 2;
network_button.Tooltip = 'Generate the network';  % Adding tooltip
network_button.Enable = 'off';
%%

% Create the results label
result = uilabel(grid, 'Text', '');
result.Layout.Row = 4; % Position for label
result.Layout.Column = 1; % Positioned in the first column

%% This function removes the rows with missing numbers
function load_data_callback(~, ~, f)
    % Define a persistent variable to store the last used path
    persistent lastUsedPath

    % Check if the lastUsedPath is valid and not empty
    if isempty(lastUsedPath) || ~isfolder(lastUsedPath)
        lastUsedPath = pwd; % Default to the current working directory
    end

    % Modify the uigetfile call to start in the last used directory
    [file, path] = uigetfile(fullfile(lastUsedPath, '*.xlsx','*.tsv'), 'Select a data file');

    % Check if the user canceled the file selection
    if isequal(file, 0)
        return
    else
        % Update the lastUsedPath
        lastUsedPath = path;
    end

    % Initialize the waitbar
    wb = waitbar(0, 'Loading data...', 'Name', 'Processing', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(wb, 'canceling', 0)

    % Read the data from the file
    try
        [fPath, fName, fExt] = fileparts(file);
        waitbar(0.2, wb, 'Reading data...');
               
               if strcmp(fExt,'.tsv')
               data_table = readtable(fullfile(path, file), "FileType","text",'Delimiter', '\t');
               data_table=rows2vars(data_table) ;
               else
                   data_table = readtable(fullfile(path, file));
               end
    catch
        errordlg('Error reading data. Please check the format of the data file.');
        delete(wb) % Close the waitbar if an error occurs
        return
    end

    % Load gene list from a text file
    [geneFile, genePath] = uigetfile('*.txt', 'Select the gene list file');
    if ~isequal(geneFile, 0)
        geneList = readlines(fullfile(genePath, geneFile));
        geneList = lower(geneList); % Convert gene list to lower case

        % Filter the data table to include only columns that match the gene list
        waitbar(0.6, wb, 'Filtering data...');
        variableNamesLower = lower(data_table.Properties.VariableNames); % Convert column names to lower case
        filteredColumns = data_table(:, ismember(variableNamesLower, geneList));

        % Keep the first column and concatenate with filtered columns
        data_table = [data_table(:, 1), filteredColumns];
    end

    % Check for Cancel button press
    if getappdata(wb, 'canceling')
        delete(wb)
        return
    end
    
    waitbar(1, wb, 'Done loading data');
    pause(1) % For user to notice the message
    delete(wb) % Close waitbar dialog box

    % Set the data table in the GUI
    data.Data = data_table;
    calculate_button.Enable = 'on'; % Enable the "Calculate Correlations" button

    % Display the filtered or unfiltered data in the Command Window
    disp(data_table);

    % Save the data table to the app data
    setappdata(f, 'data_table', data_table);
    uifigureOnTop(f, true) 
end





%% Define the "Calculate Correlations" callback function
function calculate_correlations_callback(~, ~, f)
    f.WindowStyle = 'normal';
    uifigureOnTop (f, false)

    % Get the data table from the app data
    data_table = getappdata(f, 'data_table');

    % Ignore the first column
     data_table(:, 1) = [];

    % Initialize the waitbar
    wb = waitbar(0, 'Calculating correlations...', 'Name', 'Processing', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(wb, 'canceling', 0)
    
    % Calculate the pairwise correlations
    waitbar(0.2, wb, 'Calculating correlations...');
   correlations = corrcoef(table2array(data_table)).^1;



        % Check for Cancel button press
    if getappdata(wb, 'canceling')
        delete(wb)
        return
    end
    
    waitbar(1, wb, 'Done calculating correlations');
    pause(1) % For user to notice the message
    delete(wb) % Close waitbar dialog box

    

     % Find and print NaN values
    [nan_rows, nan_cols] = find(isnan(correlations));
    if ~isempty(nan_rows)
        disp('NaN correlations found at:');
        for i = 1:length(nan_rows)
            fprintf('Row: %d, Column: %d\n', nan_rows(i), nan_cols(i));
        end
    end


    % Set the results in the GUI
    f.Name = ['IVCCA: Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = correlations;
    data.ColumnName = data_table.Properties.VariableNames;
    data.RowName = data_table.Properties.VariableNames;
    
    % Keep the first column editable after updating the data
    columnEditable = false(1, size(correlations, 2));
    columnEditable(1) = true;
    data.ColumnEditable = columnEditable;
    

    % Save the correlations to the app data
    setappdata(0, 'correlations', correlations);
    setappdata(0, 'variable_names', data_table.Properties.VariableNames);
    
    % Enable buttons
     
    sort_button.Enable = 'on';
    sort_path_button.Enable = 'on';
    elbow_button.Enable = 'on';
    sort_mpath_button.Enable = 'on';
    cluster_button.Enable = 'on'; 
    dynamic_tree_button.Enable = 'on';
    single_to_group_button.Enable = 'on';
    single_to_path_button.Enable = 'on';
    compare_paths_button.Enable = 'on';
    tsne_button.Enable = 'on';
    network_button.Enable = 'on';


    f.WindowStyle = 'normal';
%     uifigureOnTop (f, true)
%     Create a figure for the heatmap
    figure ('Name', 'IVCCA: Correlation Histogram', 'NumberTitle', 'off','Position',[100 300 400 400])
    histogram (correlations)
    title('Correlation Histogram');
    xlabel('Pairwise Correlation Coefficient, q');
    ylabel('Number of genes');

%   Create a figure for the heatmap
    
    figure('Name', 'IVCCA: Correlation Heatmap', 'NumberTitle', 'off', 'Position', [100, 100, 400, 400]);
    imagesc(tril(correlations)); % Create a heatmap
    colorbar; % Add a colorbar
    colormap('parula'); % Set the colormap
    title('Correlation Heatmap');
    xticks(1:length(data_table.Properties.VariableNames));
    yticks(1:length(data_table.Properties.VariableNames));
    xticklabels(data_table.Properties.VariableNames);
    yticklabels(data_table.Properties.VariableNames);
    
end


%% Define the "Graph" callback function
function graph_callback(~, ~, f)    
    
    f.WindowStyle = 'normal';
%     uifigureOnTop (f, true)
    % Get the sorted correlations and variable names from the app data
    correlations = getappdata(f, 'sorted_correlations');
    variable_names = getappdata(f, 'sorted_variable_names');

    % Remove the upper triangle of the matrix
    correlations = tril(correlations);

    % Convert all numbers to absolute values
    correlations = abs(correlations);

    % Create a new figure for the heatmap
    folder = fileparts(mfilename('fullpath'));
    iconFilePath = fullfile(folder, 'Images', 'Corr_icon.png');
    setIcon(gcf, iconFilePath)
    figure('Name', 'IVCCA: Sorted Correlation Heatmap', 'NumberTitle', 'off', "Position",[800,100, 400,400]);
    h = imagesc(correlations); % Create a heatmap
    colorbar; % Add a colorbar

    % Modify colormap
    cm = jet(256); % Create jet colormap
    cm(1,:) = [0.5 0.5 0.5]; % Change the first color (for zero values) to grey
    colormap(cm); % Apply the modified colormap

    title('Sorted Correlation Heatmap');
    xticks(1:length(variable_names));
    yticks(1:length(variable_names));
    xticklabels(variable_names);
    yticklabels(variable_names);
    
%     % Optionally add correlation numbers on the heatmap
%     [r,c] = size(correlations);
%     for i = 1:r
%         for j = 1:c
%             text(j, i, num2str(correlations(i,j), '%0.2f'), 'HorizontalAlignment', 'center', 'Color', 'k');
%         end
%     end
    
%     % Set color of zero values to grey
%     h.CDataMapping = 'scaled'; 
%     caxis([-1 1]); 
end


%% Define the "Sort" callback function
function sort_callback(~, ~, f)
    f.WindowStyle = 'normal';
        % Initialize the waitbar
    hWaitBar = waitbar(0, 'Initializing...');

%     uifigureOnTop (f, true)
    % Get the correlations and variable names from the app data
    correlations = getappdata(0, 'correlations');
    variable_names = getappdata(0, 'variable_names');

 %% Option 1: Select random genes (uncomment when needed)
%     random_indices = randperm(length(variable_names), 50); % put any nubmer instead of 50
%     correlations = correlations(random_indices, random_indices);
%     variable_names = variable_names(random_indices);


% Fill NaN values in data with 0 (or any other suitable number)
correlations = fillmissing(correlations, 'constant', 0);


    % Calculate the sum of absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices);  % Also sort the sum of absolute correlations
   
    % Calculate the sum of global absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Update the waitbar 
    waitbar(0.2, hWaitBar, 'Calculates the sum of global absolute correlation...');
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');

    % Update the waitbar 
    waitbar(0.4, hWaitBar, 'Sort the sums in descending order...');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices); 
    
    % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
     % Update the waitbar a
    waitbar(0.8, hWaitBar, ' Excluding self-correlation...');
  
    % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = sorted_correlations;
    data.ColumnName = sorted_variable_names;
    data.RowName = sorted_variable_names;
    waitbar(0.9, hWaitBar, ' Update the data in the table...');
    % Save the sorted correlations and variable names to the app data
    setappdata(f, 'sorted_correlations', sorted_correlations);
    setappdata(f, 'sorted_variable_names', sorted_variable_names);
    waitbar(1, hWaitBar, ' Completed...');
    close(hWaitBar);
    % Set the results in the GUI
    f.Name = ['IVCCA: Sorted Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];

  % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
  
    % Create a new uifigure for the sorted data

% Modify the title of uifigure to include the file_name

if exist('file_name', 'var') && ~isempty(file_name)
    title_str = ['IVCCA: List of Correlated Genes from ' file_name];
else
    title_str = 'IVCCA: List of Correlated Genes';
end

sorted_fig = uifigure('Name', [title_str ' PCI_A (from Global: ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');

% Create a uitable in the new uifigure
sorted_data = uitable(sorted_fig);


array=[];
 for j =1:length(sorted_correlations)
        
%%
        var= top_variable_names';
        matching_indices = find(cellfun(@(x) isequal(x, sorted_variable_names{j}), var));
        cor= average_abs_correlation;
        array{j}= cor(matching_indices);
        
 end
 
 % Display gene correlations in the new uitable

sorted_data.Data = [top_variable_names', num2cell(average_abs_correlation)]; % Removed the third column
sorted_data.ColumnName = {'Gene', 'Average Global Correlation'}; % Retained two column names
sorted_data.Position = [20 20 560 360];  

setappdata(0,'cor_variable',top_variable_names')
setappdata(0,'cor_value',average_abs_correlation)

% Enable sorting for the first column (Gene)
sorted_data.ColumnSortable(1) = true;

% Enable sorting for the second column (Average Absolute Correlations)
sorted_data.ColumnSortable(2) = true;

graph_button.Enable = 'on'; 
    
end

    function sort_path_callback(~, ~, f)
    f.WindowStyle = 'normal';
%     uifigureOnTop (f, true)
    % Get the correlations and variable names from the app data
    correlations2 = getappdata(0, 'correlations');
    variable_names2 = getappdata(0, 'variable_names');

% Define a persistent variable to store the last used path
    persistent lastUsedPath_p

    % Check if the lastUsedPath is valid and not empty
    if isempty(lastUsedPath_p) || ~isfolder(lastUsedPath_p)
        lastUsedPath_p = pwd; % Default to the current working directory
    end

    % Modify the uigetfile call to start in the last used directory
    [file_name, path_name] = uigetfile(fullfile(lastUsedPath_p, '*.txt'), 'Select a text file containing gene names');

if isequal(file_name, 0)
    disp('User selected Cancel');
    return;
else
    % Update the lastUsedPath_p with the correct variable
    lastUsedPath_p = path_name;  % Use path_name instead of path

    % Read gene names from the selected file
    file_path = fullfile(path_name, file_name);
    selected_genes = textread(file_path, '%s');
    
    % Convert both lists of genes to lowercase for case-insensitive matching
    selected_genes_lower = lower(selected_genes);
    variable_names_lower = lower(variable_names2);
    
    % Match these genes with variable_names to get indices
    [~, indices] = ismember(selected_genes_lower, variable_names_lower);
    
    % Filter out non-matching genes (indices == 0)
    valid_indices = indices(indices > 0);

    % Check if there are no valid indices and display a message box if true
if isempty(valid_indices)
    uialert(f, 'The dataset does not have genes associated with the pathway.', 'No Match Found');
    % msgbox('The pathway does not have genes associated with the dataset.', 'No Match Found');
    return;
end
    
    correlations = correlations2(valid_indices, valid_indices);
    variable_names = variable_names2(valid_indices);
end
     
    % Calculate the sum of absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices);  % Also sort the sum of absolute correlations
      
    % Calculate the sum of global absolute correlations for each variable (gene)   
    sum_abs_correlations2 = sum(abs(correlations2), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices2] = sort(sum_abs_correlations2, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations2 = correlations2(sorted_indices2, sorted_indices2);
    sorted_variable_names2 = variable_names2(sorted_indices2);
    sorted_sum_abs_correlations2 = sum_abs_correlations2(sorted_indices2); 
    
     % List of average correlations
    total_genes2 = sqrt(numel(correlations2));
    top_variable_names2 = sorted_variable_names2(1:total_genes2);
    top_sum_abs_correlations2 = sorted_sum_abs_correlations2(1:total_genes2); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation2 = top_sum_abs_correlations2 / (total_genes2 - 1);
    mean_average_abs_correlation2 = sum(average_abs_correlation2)/total_genes2;
    
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = sorted_correlations;
    data.ColumnName = sorted_variable_names;
    data.RowName = sorted_variable_names;

    % Save the sorted correlations and variable names to the app data
    setappdata(f, 'sorted_correlations', sorted_correlations);
    setappdata(f, 'sorted_variable_names', sorted_variable_names);

    % Set the results in the GUI
    f.Name = ['IVCCA: Sorted Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];

  % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
  % Create a new uifigure for the sorted data

% Modify the title of uifigure to include the file_name

if exist('file_name', 'var') && ~isempty(file_name)
    title_str = ['List of Correlated Genes from ' file_name];
else
    title_str = 'List of Correlated Genes from Random';
end

array=[];
 for j =1:length(sorted_correlations)
        
        var= top_variable_names2';
        matching_indices = find(cellfun(@(x) isequal(x, sorted_variable_names{j}), var));
        cor= average_abs_correlation2;
        array{j}= cor(matching_indices);
        
 end
        modified_title = [title_str ' PCI_A=' num2str(mean_average_abs_correlation) ', PCI_B='  num2str(mean([array{:}]))];
        % sorted_fig = uifigure('Name', [title_str ' (PCI from the Pathway): ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
        sorted_fig = uifigure('Name', modified_title, 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
        % Create a uitable in the new uifigure
        sorted_data = uitable(sorted_fig);
         % Display gene correlations in the new uitable
        sorted_data.Data = [top_variable_names', num2cell(average_abs_correlation),array'];  % Add sum of absolute correlations to the table
        sorted_data.ColumnName = {'Gene', 'PCI_A: Correlation within the Pathway','PCI_B: Correlation Extracted from Global'};  % Update column names
        sorted_data.Position = [20 20 560 360];  
        
        setappdata(0,'cor_variable',top_variable_names2')
        setappdata(0,'cor_value',average_abs_correlation2)
        % Enable sorting for the first column (Gene)
        sorted_data.ColumnSortable(1) = true;
        
        % Enable sorting for the second and third columns
        sorted_data.ColumnSortable(2) = true;
        sorted_data.ColumnSortable(3) = true;
        
    
end


%% Perform clustering
function cluster_callback(~, ~, f)
    % Get the correlations and variable names from the app data
    correlations = getappdata(0, 'correlations');
    correlations = abs(correlations);
    variable_names = getappdata(0, 'variable_names');

    % Perform hierarchical clustering
    dists = pdist(correlations, 'euclidean');
    links = linkage(dists, 'average');
    cluster_order = optimalleaforder(links, dists);
    
    % Prompt for color threshold
    prompt = {'Enter color threshold:'};
    title = 'Color Threshold';
    dims = [1 35];
    definput = {'3'}; % default value, adjust as necessary
    f.WindowStyle = 'normal';

    answer = inputdlg_id(prompt, title, dims, definput);
    colorThreshold = str2double(answer{1}); 

    % Create a dendrogram
    folder = fileparts(mfilename('fullpath'));
    iconFilePath = fullfile(folder, 'Images', 'Corr_icon.png');
    setIcon(figure, iconFilePath)
    
   [H,T,outperm] = dendrogram(links, 0, 'Orientation','top', 'Reorder',cluster_order, 'colorThreshold', colorThreshold); % Create a dendrogram
    set(H, 'LineWidth', 1);  % Set to desired line width
    ylabel('Distance')
  

% Create a dendrogram
[H,T,outperm] = dendrogram(links, 0, 'Orientation','top', 'Reorder',cluster_order, 'colorThreshold', colorThreshold);
set(H, 'LineWidth', 1);  % Set to desired line width
ylabel('Distance')

% Get the current figure and add a button for searching genes
fig = gcf; % Get the current figure handle
btn = uicontrol('Style', 'pushbutton', 'String', 'Find Gene',...
        'Position', [20 20 100 30], 'Callback', @findGeneCallback);

% Callback function for the button Find the Gene
function findGeneCallback(~, ~)
    gene_prompt = {'Enter the gene name to find:'};
    gene_title = 'Find Gene';
    gene_answer = inputdlg(gene_prompt, gene_title, dims);

    % Process the gene name if provided
    if ~isempty(gene_answer) && ~isempty(gene_answer{1})
        gene_name = lower(gene_answer{1}); % Convert input gene name to lower case
        lower_variable_names = lower(variable_names); % Convert all variable names to lower case

        gene_idx = find(strcmp(lower_variable_names, gene_name));

        if ~isempty(gene_idx)
            % Find the position of the gene on the x-axis
            x_axis_pos = find(outperm == gene_idx);

            % Highlight the gene name on the x-axis
            xticklabels = get(gca, 'XTickLabel');
            xticklabels{x_axis_pos} = ['\bf\color{red}' xticklabels{x_axis_pos}];
            set(gca, 'XTickLabel', xticklabels);

            disp(['Highlighted gene ' gene_name ' on the x-axis.']);
        else
            disp(['Gene ' gene_name ' not found among the variable names.']);
        end
    end
end




% Find the current figure and turn off the number title
fig = gcf; % Get the current figure handle
set(fig, 'NumberTitle', 'off', 'Name', 'Dendrogram');

    xticklabels(variable_names(outperm));
    xtickangle(45); % Rotate the x-axis labels
   
    % Reorder the correlations and variable names based on the clustering
    clustered_correlations = correlations(cluster_order, cluster_order);
    clustered_variable_names = variable_names(cluster_order);

    % Update the data in the existing uitable
    data.Data = clustered_correlations;
    data.ColumnName = clustered_variable_names;
    data.RowName = clustered_variable_names;

    % Save the clustered correlations and variable names to the app data
    setappdata(f, 'clustered_correlations', clustered_correlations);
    setappdata(f, 'clustered_variable_names', clustered_variable_names);
    
    % Set the results in the GUI
    f.Name = ['IVCCA: Clustered Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];
    
    % Enable the "Graph" button
    graph_button.Enable = 'on';
    
    dynamic_tree_button.Enable = 'on';

    % Compute the number of clusters at the colorThreshold
    num_clusters_color_threshold = size(links, 1) + 1 - sum(links(:,3) < colorThreshold);

    % Print the number of clusters at the color threshold
    disp(['Number of clusters with unique color: ', num2str(num_clusters_color_threshold)]);
    
% Assign clusters and extract variable names for each cluster
cluster_assignments = cluster(links, 'Cutoff', colorThreshold, 'Criterion', 'distance');
unique_clusters = unique(cluster_assignments);

% Create a cell array to store cluster information
cluster_info = cell(length(unique_clusters), 4);

for i = 1:length(unique_clusters)
    cluster_num = unique_clusters(i);
    variables_in_cluster = variable_names(cluster_assignments == cluster_num);
    
    % Calculate the sum of absolute correlations for the genes in the cluster
    cluster_correlation_values = abs(correlations(cluster_assignments == cluster_num));
    sum_abs_correlation = sum(cluster_correlation_values, 'all');
    
    % Store cluster information as strings
    cluster_info{i, 1} = uint8(cluster_num);
    cluster_info{i, 2} = length(variables_in_cluster); % Number of genes in the cluster
    
    cluster_info{i, 4} = strjoin(variables_in_cluster, ', ');     
    
    % Display cluster information using fprintf
    fprintf('Cluster %d: %s\n', cluster_num, strjoin(variables_in_cluster, ', '));
    sum_cor=0;
    for j =1:length(variables_in_cluster)
        
        var= getappdata(0,'cor_variable');
        matching_indices = find(cellfun(@(x) isequal(x, variables_in_cluster{j}), var));
        cor= getappdata(0,'cor_value');
        sum_cor=sum_cor+abs(cor(matching_indices));
    end
    cluster_info{i, 3} = sum_cor/length(variables_in_cluster);
end

% Create a new uifigure to display cluster information
cluster_info_fig = uifigure('Name', 'Cluster Information', 'Position', [800, 250, 400, 300]);
cluster_info_table = uitable(cluster_info_fig,'CellSelectionCallback', @cellSelectedCallback);
button = uibutton(cluster_info_fig, 'Text', 'API String', 'Position', [350, 60, 80, 30], 'ButtonPushedFcn', @(btn, event) api_to_string_2());
cluster_info_table.Data = cluster_info;
cluster_info_table.ColumnName = {'Cluster Number', 'Number of Genes','PCI','Gene Names'};
cluster_info_table.Position = [20, 20, 360, 260];

% Enable sorting for the first column (cluster number)
cluster_info_table.ColumnSortable(1) = true;

% Enable sorting for the second column (number of genes)
cluster_info_table.ColumnSortable(2) = true;

% Enable sorting for the second column (Index)
cluster_info_table.ColumnSortable(3) = true;



end
%%

function cellSelectedCallback(src, event)
    selectedRow = event.Indices(1);
    selectedColumn = event.Indices(2);

    if ~isempty(selectedRow) && ~isempty(selectedColumn)
        % Get the data from the selected cell
        selectedData = src.Data{selectedRow, selectedColumn};

        % Display information about the selected cell
%         disp(['Selected Row: ' num2str(selectedRow)]);
%         disp(['Selected Column: ' num2str(selectedColumn)]);
%         disp(['Selected Data: ' num2str(selectedData)]);
       setappdata(0,'genes', num2str(selectedData))
    end
    
end
%% Define the "Elbow Curve" and Silhouette callback functions
function elbow_curve_callback(~, ~, f)
    % Initialize the waitbar
    hWaitBar = waitbar(0, 'Initializing...');

    correlations = getappdata(0, 'correlations');  % Get correlations from app data
    correlations = abs(correlations);
    % Initialize the waitbar
    waitbar(0.2, hWaitBar, 'Performing Elbow computation...');

    maxK = 30;  % Maximum number of clusters to check

    sum_of_squared_distances = zeros(maxK, 1);
    silhouette_vals = zeros(maxK-1, 1);  % No silhouette for K = 1
    
    for k = 1:maxK
        [idx, ~, sumD] = kmeans(correlations, k);
        sum_of_squared_distances(k) = sum(sumD);
    end    
   waitbar(0.4, hWaitBar, 'Performing Silhouette computation...');
    for k = 2:maxK  % Start from 2 clusters
        [idx, ~] = kmedoids(correlations, k);
        
        % Compute silhouette values for this cluster count
        s = silhouette(correlations, idx, 'sqEuclidean');
        silhouette_vals(k-1) = mean(s);
    end

waitbar(0.8, hWaitBar, 'Plotting...');
% Create a subplot to show both elbow and silhouette plots side by side
    figure ('Name', 'IVCCA: Number of clusters', 'NumberTitle', 'off');
    
    subplot(1, 2, 1);
    plot(1:maxK, log(sum_of_squared_distances), 'bo-');
    title('Elbow Curve');
    xlabel('Number of clusters (K)');
    ylabel('log(Sum of Squared Distances)');
    
    subplot(1, 2, 2);
    plot(2:maxK, silhouette_vals, 'r*-');
    title('Silhouette Analysis ');
    xlabel('Number of clusters (K)');
    ylabel('Average Silhouette Value');
    waitbar(1, hWaitBar, 'Complete...');
    close(hWaitBar);
end

%% Dynamic_tree_cut function
function dynamic_tree_cut_callback(~, ~, f)
    % Get the correlations from the app data
    correlations = getappdata(0, 'correlations');
    correlations = abs(correlations);
    variable_names = getappdata(0, 'variable_names');
    
    % Ask the user to specify cutoff_cl
    prompt = {'Enter cutoff value (default is 0.15):'};
    dlgtitle = 'Cutoff Input';
    dims = [1 35];
    definput = {'0.15'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    % If the user presses Cancel, the answer is empty. 
    if isempty(answer)
        disp('User cancelled the operation.');
        return;
    end
    
    % Convert the answer to a numeric value
    cutoff_cl = str2double(answer{1});
    
    % Check if input is valid
    if isnan(cutoff_cl) || cutoff_cl < 0 || cutoff_cl > 1
        errordlg('Invalid input. Please enter a value between 0 and 1.', 'Error');
        return;
    end
     % Perform hierarchical clustering
    Z = linkage(correlations, 'average');
    % Use inconsistency method to initially determine the number of clusters
    T = cluster(Z, 'Cutoff', cutoff_cl * max(Z(:,3)), 'Criterion', 'distance'); % Larger cutoff value corresponds to fewer clusters

    % Display the number of members in each cluster in the Command Window
    unique_clusters = unique(T);
    disp('Cluster Results:');
    for i = 1:length(unique_clusters)
        cluster_members = variable_names(T == unique_clusters(i));
        disp(['Cluster ' num2str(i) ' (Size: ' num2str(length(cluster_members)) '):']);
        disp(strjoin(cluster_members, ', '));
    end

    % Use inconsistency method to initially determine the number of clusters
    T = cluster(Z, 'Cutoff', cutoff_cl * max(Z(:,3)), 'Criterion', 'distance'); % Larger cutoff value corresponds to fewer clusters

    % Save the cluster assignments to the app data for further processing
    setappdata(f, 'dynamic_tree_clusters', T);
    
    % Organize the correlation matrix according to the clusters
    [~, order] = sort(T);
    ordered_correlations = correlations(order, order);
    
    % Create a heatmap using the ordered correlation matrix
    figure ('Name', 'IVCCA: Dynamic Tree Cutting', 'NumberTitle', 'off');
    imagesc(ordered_correlations);
    colorbar;
    num_clusters = length(unique_clusters);
    title(['Clustered Correlation Matrix using Dynamic Tree Cutting (', num2str(num_clusters), ' Clusters)']);

   
    xticks(1:length(variable_names));
    yticks(1:length(variable_names));
    xticklabels(variable_names(order));
    yticklabels(variable_names(order));
    colormap('parula');
    caxis([-1, 1]); % Assuming correlations range from -1 to 1

% Calculate the mean value of absolute correlations for each cluster
    unique_clusters = unique(T);
    cluster_mean_abs_correlations = zeros(length(unique_clusters), 1);

    for i = 1:length(unique_clusters)
        cluster_indices = find(T == unique_clusters(i));
        cluster_correlations = ordered_correlations(cluster_indices, cluster_indices);
        cluster_mean_abs_correlations(i) = mean(abs(cluster_correlations), 'all');
    end

    % Display the mean value of absolute correlations for each cluster
    disp('Mean Absolute Correlations in Clusters:');
    for i = 1:length(unique_clusters)
        disp(['Cluster ' num2str(i) ': ' num2str(cluster_mean_abs_correlations(i))]);
    end
end

%% Define a callback function for calculating single gene-to-group correlations
function single_to_group_correlation_callback(~, ~, f)
    % Get the data table from the app data
    data_table = getappdata(f, 'data_table');

   % Ask the user for the name of the single gene
single_gene_name = inputdlg('Enter the name of the single gene:');
if isempty(single_gene_name)
    errordlg('No gene name was provided.');
    return;
end
single_gene_name = single_gene_name{1};

% Convert both input and variable names in the data table to lowercase for case-insensitive comparison
single_gene_name_lower = single_gene_name;
data_table_variable_names_lower = data_table.Properties.VariableNames;

% Validate if the single gene name exists in the data, ignoring case
single_gene_index = find(strcmpi(data_table_variable_names_lower, single_gene_name_lower));
if isempty(single_gene_index)
    errordlg('The specified gene was not found in the data.');
    return;
end

    % Ask the user for the names of the group of genes (could be via a list box or another method)
    [group_gene_indices, group_gene_names] = listdlg('ListString',data_table.Properties.VariableNames, ...
                                                     'SelectionMode','multiple', ...
                                                     'PromptString',{'Select the group of genes:'});
group_gene_names={};
for i=1:length(group_gene_indices)
    k=group_gene_indices(i);
    group_gene_names{i}=data_table.Properties.VariableNames{k};
end
% Debugging line to check the names
disp(group_gene_names);  % This should print the selected gene names in the Command Window

    if isempty(group_gene_indices)
        errordlg('No genes were selected.');
        return;
    end

    % Extract the data for the single gene and the group of genes
    single_gene_data = table2array(data_table(:, single_gene_index));
    group_genes_data = table2array(data_table(:, group_gene_indices));

    % Calculate the correlation between the single gene and the group of genes
    single_to_group_correlations = arrayfun(@(idx) corr(single_gene_data, group_genes_data(:, idx)), 1:size(group_genes_data, 2));
    
    % Calculate the average of the absolute values of the correlation coefficients
    avg_abs_correlation = mean(abs(single_to_group_correlations));
    
    % Display or plot the results
    figure ('Name', 'IVCCA: Single gene to other genes', 'NumberTitle', 'off');

hold on; % Hold on to the current figure
for i = 1:length(single_to_group_correlations)
    if single_to_group_correlations(i) < 0
        bar(i, single_to_group_correlations(i), 'FaceColor', 'r', 'EdgeColor', 'r'); % Negative correlations in red
    else
        bar(i, single_to_group_correlations(i), 'FaceColor', 'b', 'EdgeColor', 'b'); % Positive correlations in blue
    end
end

    % Include the average of the absolute correlations in the title
    title_str = sprintf('Correlation of %s to selected group of genes (Avg. Abs. Corr. = %.2f)', single_gene_name, avg_abs_correlation);
    title(title_str);
    
    ylabel('Correlation Coefficient');
    xticks(1:length(group_gene_names));
    xticklabels(group_gene_names);
    xtickangle(45); % Angle the labels for readability
    set(gcf, 'Position', [200, 200, 700, 500]); % Set the position of the figure
   
end   
    
%% Define a callback function for calculating single gene-to-pathway correlations
function single_to_pathway_correlation_callback(~, ~, f)
    % Get the data table from the app data
    data_table = getappdata(f, 'data_table');

    % Ask the user for the name of the single gene
    single_gene_name = inputdlg('Enter the name of the single gene:');
    if isempty(single_gene_name)
        errordlg('No gene name was provided.');
        return;
    end
    single_gene_name = single_gene_name{1};


% Convert both the input and the data table gene names to lower case for comparison
single_gene_name_lower = single_gene_name;
data_table_gene_names_lower = data_table.Properties.VariableNames;

% Validate if the single gene name exists in the data, ignoring case
single_gene_index = find(strcmpi(data_table_gene_names_lower, single_gene_name_lower));
if isempty(single_gene_index)
    errordlg('The specified gene was not found in the data.');
    return;
end
 
    % Ask the user for the txt file containing the list of genes
    [file, path] = uigetfile('*.txt', 'Select the txt file with the list of genes');
    if isequal(file, 0)
        return
    end
    
    % Read the list of genes from the file
    fileID = fopen(fullfile(path, file), 'r');
    genes_list = textscan(fileID, '%s');
    fclose(fileID);
    genes_list = genes_list{1}; % Convert from cell array to simple string array

    % Find the indices of the genes in the list that are present in the data
    [~, pathway_gene_indices] = ismember(genes_list, data_table.Properties.VariableNames);
    pathway_gene_indices(pathway_gene_indices == 0) = []; % Remove genes not found in the data

    % Extract the data for the single gene and the pathway genes
    single_gene_data = table2array(data_table(:, single_gene_index));
    pathway_genes_data = table2array(data_table(:, pathway_gene_indices));

    % Calculate the correlation between the single gene and each gene in the pathway
    single_to_pathway_correlations = arrayfun(@(idx) corr(single_gene_data, pathway_genes_data(:, idx)), 1:size(pathway_genes_data, 2));

    % Calculate the average of the absolute values of the correlation coefficients
    avg_abs_correlation = mean(abs(single_to_pathway_correlations));

    % Display the results
     figure ('Name', 'IVCCA: Single gene to a pathway', 'NumberTitle', 'off');

% Display the results with color coding

hold on; 
for i = 1:length(single_to_pathway_correlations)
    if single_to_pathway_correlations(i) < 0
        bar(i, single_to_pathway_correlations(i), 'FaceColor', 'r', 'EdgeColor', 'r'); % Negative correlations in red
    else
        bar(i, single_to_pathway_correlations(i), 'FaceColor', 'b', 'EdgeColor', 'b'); % Positive correlations in blue
    end
    name{i}=data_table.Properties.VariableNames{pathway_gene_indices(i)};
end


hold off; 

% Include the file name and the average of the absolute correlations in the title

% Escape underscores to avoid them being interpreted as subscripts
escaped_single_gene_name = strrep(single_gene_name, '_', '\_');
escaped_file_name = strrep(file, '_', '\_');
title_str = sprintf('Correlation of %s to genes in %s (Avg. Abs. Corr. = %.2f)', escaped_single_gene_name, escaped_file_name, avg_abs_correlation);
title(title_str);

ylabel('Correlation Coefficient');
xticks(1:length(pathway_genes_data));
xticklabels(name);
xtickangle(45); % Angle the labels for readability
set(gcf, 'Position', [200, 200, 700, 500]); % Set the position of the figure

end

    function sort_mpath_callback(~, ~, f)
    f.WindowStyle = 'normal';

    % Define the path to the Excel file containing GO numbers and descriptions
    % Replace 'path_to_excel_file.xlsx' with the actual path to your Excel file
    excelFilePath = 'GO terms.xlsx'; 

   % Define the Excel file options
    excelFileOptions = {'GO terms 13200.xlsx', 'Kegg terms.xlsx', 'Custom_1.xlsx', 'Custom_2.xlsx', 'Custom_3.xlsx'};
    [indx, tf] = listdlg('PromptString', 'Select an Excel file:', ...
                         'SelectionMode', 'single', ...
                         'ListString', excelFileOptions);

    % If the user made a selection, read the selected Excel file
    if tf
        excelFilePath = excelFileOptions{indx};
        goDescriptions = readtable(excelFilePath, 'ReadVariableNames', true);
    else
        disp('No Excel file selected. Exiting function.');
        return;
    end

    % Read the Excel file
    goDescriptions = readtable(excelFilePath, 'ReadVariableNames', true); 

    % Get the correlations and variable names from the app data
    correlations2 = getappdata(0, 'correlations');
    variable_names2 = getappdata(0, 'variable_names');
   
    s_variable_names = getappdata(0,'cor_variable');
    s_correlations = getappdata(0,'cor_value');

    % Define a persistent variable to store the last used path
    persistent lastUsedPath_p
    if isempty(lastUsedPath_p) || ~isfolder(lastUsedPath_p)
        lastUsedPath_p = pwd; % Default to the current working directory
    end

    % Modify the uigetfile call to allow multiple file selection
    [file_names, path_name] = uigetfile(fullfile(lastUsedPath_p, '*.txt'), 'Select one or more text files containing gene names', 'MultiSelect', 'on');

    if isequal(file_names, 0)
        disp('User selected Cancel');
        return;
    else
        lastUsedPath_p = path_name;  % Update the lastUsedPath_p

        if ischar(file_names)  % If only one file is selected, convert it to a cell array
            file_names = {file_names};
        end

        % Initialize the table data with an additional column for GO descriptions
        tableData = cell(length(file_names), 6);

for i = 1:length(file_names)
    file_path = fullfile(path_name, file_names{i});
    selected_genes = textread(file_path, '%s');

    % Extract the identifier from the file name, handling both 'GO_' and 'path_mmu' formats
    identifier = regexp(file_names{i}, '(GO_\d+|path_mmu\d+)', 'match', 'once');

    % Find the corresponding description in the Excel file
    goIndex = find(strcmp(goDescriptions{:,1}, identifier));
    if ~isempty(goIndex)
        goDescription = goDescriptions{goIndex, 2};
    else
        % Use a modified file name as the description if not found
        % Example modification: remove file extension, replace underscores with spaces
        goDescription = strrep(file_names{i}, '_', ' ');
        goDescription = regexprep(goDescription, '\.[^.]*$', ''); % Remove file extension
    end

    % Convert all gene names to lower case for case-insensitive comparison
    selected_genes_lower = lower(selected_genes); 
    variable_names_lower = lower(variable_names2);
    s_variable_names_lower = lower(s_variable_names); % Convert to lower case for comparison

    
    [~, indices] = ismember(selected_genes_lower, variable_names_lower');
    valid_indices = indices(indices > 0);
            
            if isempty(valid_indices)
                continue; % Skip this file if no valid genes are found
            end
            
            correlations = correlations2(valid_indices, valid_indices);
            
            % Calculation of pciA (internally correlated)
            sum_abs_correlations = sum(abs(correlations), 2) - 1;
            average_abs_correlation = sum_abs_correlations / (length(valid_indices) - 1);
            pciA = mean(average_abs_correlation);

            % Calculate pciB with case-insensitive comparison
    matching_indices = ismember(s_variable_names_lower, selected_genes_lower);
    if any(matching_indices)
        pciB = mean(s_correlations(matching_indices));
    else
        pciB = NaN; % Handle cases where there are no matches
    end
  
            % Calculate the total number of genes in each pathway (from the text file)
            totalGenesInPathway = num2str(length(selected_genes)); % Total genes in the pathway from the file

            % Calculate the number of genes found in the set
            genesFoundInSet = num2str(length(valid_indices)); % Genes found in the set

            % Calculate the ratio of DEGs to total genes in the pathway
    ratioDEGsToTotal = length(valid_indices) / length(selected_genes);
    ratioDEGsToTotalStr = num2str(ratioDEGsToTotal, '%.3f'); % Convert the ratio to a string with 2 decimal places

    ratioDEGsToTotalNum = str2double(ratioDEGsToTotalStr);
    strength_index = ratioDEGsToTotalNum*pciB*100; 

% Calculate the Z-score, from the randomly selected genes using random_sel_txt.m function. 
% The average (A!) and standard dev (STD) of  CICI from random genes was calculated and the average is in cell A1, the standard deviation is in cell B1, and 
% is in cell C1, the formula for the Z-score=(CICI-A)/ STD the values
% Avearge = 7.908.  STD = 2.0605. For alpha = 0.05, the Critical Z-value = NORM.S.INV(1-0.05/2) = 1.960  Conclusion in Z-score:If Z-score > Critical Z-score, "Significantly Different")
   
  %  CECI = str2double(tableData{i, 8});
    Z_score = (strength_index - 7.908) / 2.0605;

            % Store the results in the table data
            tableData{i, 1} = file_names{i};
            tableData{i, 2} = goDescription;  %  GO description
            tableData{i, 3} = totalGenesInPathway; %  total genes in the pathway            
            tableData{i, 4} = genesFoundInSet; %  number of genes found in the set
            tableData{i, 5} = ratioDEGsToTotalStr;  % Pathway activation Index
            tableData{i, 6} = pciA; % internal correlation to each other
            tableData{i, 7} = pciB; % Extracted from the table
            tableData{i, 8} = strength_index; % product of genesFoundInSet  and pciB multiply by 100
            tableData{i, 9} = Z_score; % internal correlation to each other
            
            
       %To get name 
       for j=1:length(valid_indices)
           number= valid_indices(j);
           name{i,j}=s_variable_names_lower{number};
       end
       for k=1:length(selected_genes)
%            number= selected_genes(j);
           name2{i,k}=selected_genes{j};
       end
        end

 % Filter out empty rows
notEmptyRows = ~all(cellfun(@isempty, tableData), 2);
filteredTableData = tableData(notEmptyRows, :);
notEmptyRows2 = ~all(cellfun(@isempty, name), 2);
name = name(notEmptyRows2, :);
notEmptyRows3 = ~all(cellfun(@isempty, name2), 2);
name2 = name2(notEmptyRows3, :);
% Define the prompt, title, and default value for the input dialog
prompt = {'Enter the minimum number of genes in a set:'};
dlgtitle = 'Input';
dims = [1 45];
definput = {'5'};  % default value set to 5

% Create the input dialog box
answer = inputdlg(prompt, dlgtitle, dims, definput);

% Check if a value was entered and if so, use it; otherwise, use the default value
if ~isempty(answer)
    genesThreshold = str2double(answer{1});
else
    genesThreshold = 5;
end

% Validate the input
if ~isempty(answer)
    tempValue = str2double(answer{1});
    if ~isnan(tempValue) && tempValue >= 0 && tempValue <= 10
        genesThreshold = tempValue;
    else
        % Optionally, you can display a message if the input is invalid
        msgbox('Invalid input. Using default value of 4.', 'Error', 'error');
    end
end


% Convert 'Genes_Found' to numeric and filter rows where genes found is more than the threshold
genesFoundNumeric = cellfun(@str2num, filteredTableData(:, 4));  % Convert to numeric
rowsWithMoreThanThresholdGenes = genesFoundNumeric >= genesThreshold;  % Find rows with more or equal than threshold genes
filteredTableData = filteredTableData(rowsWithMoreThanThresholdGenes, :);  % Apply the filter
name=name(rowsWithMoreThanThresholdGenes, :);
name2=name2(rowsWithMoreThanThresholdGenes, :);
% Create and display the table
resultTable = cell2table(filteredTableData, 'VariableNames', {'File_Name', 'GO_Description','Genes in Pathway', 'Genes_Found', 'PAI', 'PCI_B','PCI_A','CECI', 'Z-score' });

% Create a uifigure with a dynamic title that includes the threshold
figTitle = sprintf('Multiple Pathway Analysis - Showing Genes with More than %d Found in Set', genesThreshold);
fig = uifigure('Position', [50, 200, 1100, 400], 'Name', figTitle);

% Create a uitable in the uifigure with the sorted data
uit = uitable(fig, 'Data', table2cell(resultTable), 'ColumnName', {'Pathway', 'Description','Genes in Pathway', 'Genes in Set', 'PAI','PCI_A within Pathway','PCI_B Extracted from Dataset', 'Correlation-Expression Composite Index (CECI)','Z-Score' }, 'Position', [20, 20, 1100, 360],'CellSelectionCallback', @cellSelectedCallback2);

% Set column width to auto

uit.ColumnWidth = {120, 100, 100, 100, 100, 120, 120, 120, 120};

% Adding sorting functionality
uit.ColumnSortable = [true, true, true, true, true, true, true, true, true];


% Extracting goDescription and strength indices
goDescriptions = filteredTableData(:, 2);
strengthIndices = cell2mat(filteredTableData(:, 8)); %from column 8

% Sorting the data based on strength indices in descending order
[sortedStrengthIndices, sortIndex] = sort(strengthIndices, 'descend');
[sortedZscores, ~] = sort(Z_score, 'descend');
sortedGoDescriptions = goDescriptions(sortIndex);

setappdata(0,'name',name)
setappdata(0,'name2',name2)



%% Sorting and selecting the top entries based on the user input
% topGoDescriptions = sortedGoDescriptions(1:min(numEntries, end));
% topZscores = sortedStrengthIndices(1:min(numEntries, end)); % Use strength indices to sort Z-scores
% 
% % Create the horizontal bar plot for Z-score vs descriptions
% fig_z = figure;
% barh(topZscores, 'green');
% set(gca, 'YTick', 1:length(topGoDescriptions), 'YTickLabel', string(topGoDescriptions)); % Correct labels
% 
% % Add labels and title for Z-score plot
% xlabel('Z-score');
% title(sprintf('Top %d Pathways vs. Z-Score', numEntries));
% 
% % Adjust figure size and invert y-axis for Z-score plot
% fig_z.Position = [200, 200, 700, 400];
% set(gca, 'YDir', 'reverse');



%% Plotting CECI
% % Selecting the top 25 entries
% topGoDescriptions = sortedGoDescriptions(1:min(25, end));
% topStrengthIndices = sortedStrengthIndices(1:min(25, end));

% Create a pop-up to input the number of entries
prompt = {'Enter the number of entries for plotting:'};
dlgtitle = 'Input';
dims = [1 45];
definput = {'25'}; % default value
% answer = inputdlg(prompt, dlgtitle, dims, definput);
answer = inputdlg(prompt, dlgtitle, dims, definput);

numEntries = str2double(answer{1});
totalRows = size(filteredTableData, 1);
numEntries = max(2, min(numEntries, totalRows)); % Ensure within valid range

% Sorting and selecting the top entries based on the user input
topGoDescriptions = sortedGoDescriptions(1:min(numEntries, end));
topStrengthIndices = sortedStrengthIndices(1:min(numEntries, end));
topZscores = sortedZscores(1:min(numEntries, end));

% Create the horizontal bar plot
fig = figure;
barh(topStrengthIndices, 'blue');
set(gca, 'YTick', 1:length(topGoDescriptions), 'YTickLabel', string(topGoDescriptions));

% Add labels and title
xlabel('Correlation-Expression Composite Index (CECI)');
% ylabel('Pathways');
% Modify the title to include the number of entries chosen by the user
title(sprintf('Top %d Pathways vs. Correlation-Expression Composite Index (CECI)', numEntries));

% Adjust figure size and invert y-axis
fig.Position = [450, 50, 800, 400];
set(gca, 'YDir', 'reverse');

%% Z-score figure 
% Filter out entries with Z-score greater than 1.96
zScoreThreshold = 1.96; % Critical Z-score 
filteredByZscore = cell2mat(filteredTableData(:, 9)) > zScoreThreshold;  % Assuming Z-score is in column 9
filteredData = filteredTableData(filteredByZscore, :);

% Sort the filtered data based on Z-score
[sortedZscores, sortIndex] = sort(cell2mat(filteredData(:, 9)), 'descend');
sortedGoDescriptions = filteredData(sortIndex, 2);  % Assuming descriptions are in column 2

% Create the horizontal bar plot for Z-score vs descriptions
fig_z = figure;
barh(sortedZscores, 'green');
set(gca, 'YTick', 1:length(sortedGoDescriptions), 'YTickLabel', string(sortedGoDescriptions));

% Add labels and title for Z-score plot
xlabel('Z-score');
title('Pathways with statistically significant Z-Score \alpha <0.05');

% Adjust figure size and invert y-axis for Z-score plot
fig_z.Position = [50, 50, 800, 400];
set(gca, 'YDir', 'reverse');

end
    end
function cellSelectedCallback2(src, event)
    selectedRow = event.Indices(1);
    selectedColumn = event.Indices(2);

    if ~isempty(selectedRow) && ~isempty(selectedColumn)
%         % Get the data from the selected cell
%         selectedData = src.Dat
% a{selectedRow, selectedColumn};
        % Display information about the selected cell
%         disp(['Selected Row: ' num2str(selectedRow)]);
%         disp(['Selected Column: ' num2str(selectedColumn)]);
%         disp(['Selected Data: ' num2str(selectedData)]);
      if selectedColumn==4
       names= getappdata(0,'name');
       show= names(selectedRow,:);
       fig = uifigure('Position', [50, 200, 1100, 400], 'Name', 'Genelist');
       uit = uitable(fig, 'Data', show, 'Position', [20, 20, 1100, 360]);
      elseif selectedColumn==3
               names= getappdata(0,'name2');
       show= names(selectedRow,:);
       fig = uifigure('Position', [50, 200, 1100, 400], 'Name', 'Genelist');
       uit = uitable(fig, 'Data', show, 'Position', [20, 20, 1100, 360]);
       end
    end
    
end

function calculate_network_callback(~, ~, f)
    f.WindowStyle = 'normal';

    % Retrieve correlation data and variable names (gene names)
    cor_data = getappdata(0, 'correlations');
    geneNames = getappdata(0, 'variable_names');

    % Define the prompt, title, and default value for the input dialog
    prompt = {'Enter the correlation threshold:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'0.75'}; % default value set to 0.75

    % Create the input dialog box
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Validate and parse the input
    correlationThreshold = 0.75; % Default threshold
    if ~isempty(answer)
        tempValue = str2double(answer{1});
        if ~isnan(tempValue) && tempValue >= 0 && tempValue <= 1
            correlationThreshold = tempValue;
        else
            % Display a message if the input is invalid
            msgbox('Invalid input. Using default value of 0.75.', 'Error', 'error');
        end
    end

    % Filter the correlation matrix
    filteredCorData = cor_data;
    filteredCorData(abs(filteredCorData) < correlationThreshold) = 0;

    % Create a graph object from the filtered correlation matrix
    G = graph(filteredCorData, geneNames, 'OmitSelfLoops');

    % Remove edges with weight below the threshold
    G = rmedge(G, find(G.Edges.Weight < correlationThreshold));

    % Calculate the degree for each node
    nodeDegree = degree(G);

    % Create a table with gene names and their degrees
    resultsTable = table(geneNames', nodeDegree, 'VariableNames', {'GeneName', 'Degree'});



% Set edge weights based on correlation values
G.Edges.Weight = abs(G.Edges.Weight); % Using absolute values of correlation

% Number of nodes
numNodes = numnodes(G);

% Generate spherical coordinates for each node
[x, y, z] = spherePoints(numNodes);

% Plot the network in 3D with nodes on a sphere
figure; % Open a new figure
p = plot(G, 'XData', x, 'YData', y, 'ZData', z, 'EdgeColor', 'r');

% Adjust line thickness based on correlation value
maxWeight = max(G.Edges.Weight); % Find maximum edge weight
minLineWidth = 0.5; % Minimum line width
maxLineWidth = 4; % Maximum line width
p.LineWidth = minLineWidth + ((G.Edges.Weight / maxWeight) * 0.32*(maxLineWidth - minLineWidth)).^12;

% Adjust node size based on degree
p.MarkerSize = 5 + (1.3 * (nodeDegree / max(nodeDegree))).^12;

% Set point color to yellow with transparency
pointColor = [0, 1, 0]; % Yellow color with 
p.NodeColor = pointColor;
p.EdgeAlpha = 0.5;

% Create a UI figure to display the table
figureTitle = sprintf('Degree of Connection (Threshold: %.2f)', correlationThreshold);
f = uifigure('Name', figureTitle, 'Position', [100 100 300 250]);
t = uitable('Parent', f, 'Data', resultsTable, 'Position', [20 20 260 200]);
t.ColumnSortable(1) = true;
t.ColumnSortable(2) = true;

end
function [x, y, z] = spherePoints(n)
    % Generate n points distributed on the surface of a sphere
    theta = linspace(0, 2*pi, n);
    phi = acos(2 * linspace(0, 1, n) - 1);
    x = sin(phi) .* cos(theta);
    y = sin(phi) .* sin(theta);
    z = cos(phi);
end




end



