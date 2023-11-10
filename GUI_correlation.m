function GUI_correlation
% Mikhail Berezin 2023
f = uifigure('Name', 'Inter-Variability Cross Correlation Analysis (Berezin Lab)', 'Position', [200 200 700 400], 'Icon','Corr_icon.png');  % adjusted width
close all
% f.WindowStyle = 'normal';
% uifigureOnTop (f, true) 

% Create the grid layout
grid = uigridlayout(f, [5 2], 'ColumnWidth', {'1x', '0.2x'}, 'RowHeight', {'1x', '1x', '1x', '1x', '1x'});  % now 4x2 grid, second column smaller

% Create the uitable
data = uitable(grid, 'ColumnEditable', true);
data.Layout.Row = [1 9]; % Spans across 10 rows
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

% Create the "Pathway" button
sort_path_button = uibutton(grid, 'push', 'Text', 'Pathway', 'ButtonPushedFcn', {@sort_path_callback, f});
sort_path_button.Layout.Row = 4; % Position for "Pathway" button
sort_path_button.Layout.Column = 2;
sort_path_button.Tooltip = 'Sort the correlation matrix for a seected pathway';  % Adding tooltip
sort_path_button.Enable = 'off'; % Initially disabled

% Create the "Graph" button
graph_button = uibutton(grid, 'push', 'Text', 'Graph', 'ButtonPushedFcn', {@graph_callback, f});
graph_button.Layout.Row = 5; % Position for "Graph" button
graph_button.Layout.Column = 2;
graph_button.Tooltip = 'Graph the sorted correlation matrix';  % Adding tooltip
graph_button.Enable = 'off'; % Initially disabled

% Create the "Cluster" button
cluster_button = uibutton(grid, 'push', 'Text', 'Cluster', 'ButtonPushedFcn', {@cluster_callback, f});
cluster_button.Layout.Row = 6; % Position for "Cluster" button
cluster_button.Layout.Column = 2;
cluster_button.Tooltip = 'Cluster the correlation matrix';  % Adding tooltip
cluster_button.Enable = 'off'; % Initially disabled


% Create the "Elbow Curve" button
elbow_button = uibutton(grid, 'push', 'Text', 'Elbow Curve', 'ButtonPushedFcn', {@elbow_curve_callback, f});
elbow_button.Layout.Row = 7; % Position for "Elbow Curve" button
elbow_button.Layout.Column = 2;
elbow_button.Tooltip = 'Determine optimal number of clusters';  % Adding tooltip
elbow_button.Enable = 'off'; % Initially disabled

% Create the "Dynamic Tree Cut" button
dynamic_tree_button = uibutton(grid, 'push', 'Text', 'Dynamic Tree Cut', 'ButtonPushedFcn', {@dynamic_tree_cut_callback, f});
dynamic_tree_button.Layout.Row = 8; % Position for "Dynamic Tree Cut" button
dynamic_tree_button.Layout.Column = 2;
dynamic_tree_button.Tooltip = 'Perform Dynamic Tree Cutting on the correlation matrix';  % Adding tooltip
dynamic_tree_button.Enable = 'off'; % Initially disabled

% Create the "Single to Group Correlation" button
single_to_group_button = uibutton(grid, 'push', 'Text', 'Gene to Group', ...
                                  'ButtonPushedFcn', {@single_to_group_correlation_callback, f});
single_to_group_button.Layout.Row = 9; % Choose an appropriate row
single_to_group_button.Layout.Column = 2;
single_to_group_button.Tooltip = 'Calculate the correlation of a single gene to a group of genes';
single_to_group_button.Enable = 'off'; % Initially disabled

% Create the "Single to Pathway Correlation" button
single_to_path_button = uibutton(grid, 'push', 'Text', 'Gene to Pathway', ...
                                  'ButtonPushedFcn', {@single_to_pathway_correlation_callback, f});
single_to_path_button.Layout.Row = 10; % Choose an appropriate row
single_to_path_button.Layout.Column = 2;
single_to_path_button.Tooltip = 'Calculate the correlation of a single gene to a pathway';
single_to_path_button.Enable = 'off'; % Initially disabled

% Create the results label
result = uilabel(grid, 'Text', '');
result.Layout.Row = 4; % Position for label
result.Layout.Column = 1; % Positioned in the first column

%% This function removes the rows with missing numbers
function load_data_callback(~, ~, f)
    % Get the file name
    [file, path] = uigetfile('*.xlsx', 'Select a data file');
    if isequal(file, 0)
        return
    end

    % Initialize the waitbar
    wb = waitbar(0, 'Loading data...', 'Name', 'Processing', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(wb, 'canceling', 0)

    % Read the data from the file
    try
        waitbar(0.2, wb, 'Reading data...');
        data_table = readtable(fullfile(path, file));
    catch
        errordlg('Error reading data. Please check the format of the data file.');
        delete(wb) % Close the waitbar if an error occurs
        return
    end

    % Ignore the first row
  %  data_table(1, :) = [];

    % Check that the data table has at least two columns
    if size(data_table, 2) < 2
        errordlg('Data file must have at least two columns.');
        delete(wb) % Close the waitbar if an error occurs
        return
    end

    waitbar(0.5, wb, 'Removing missing data...');
    % Remove rows with missing data
    data_table = rmmissing(data_table);

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

    % Display the loaded data in the Command Window
    disp(data_table);

    % Save the data table to the app data
    setappdata(f, 'data_table', data_table);
%     uifigureOnTop (f, true) 
end


%% Define the "Calculate Correlations" callback function
function calculate_correlations_callback(~, ~, f)
    f.WindowStyle = 'normal';
    uifigureOnTop (f, false)

    % Get the data table from the app data
    data_table = getappdata(f, 'data_table');

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

    % Set the results in the GUI
    f.Name = ['Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = correlations;
    data.ColumnName = data_table.Properties.VariableNames;
    data.RowName = data_table.Properties.VariableNames;
    
    % Keep the first column editable after updating the data
    columnEditable = false(1, size(correlations, 2));
    columnEditable(1) = true;
    data.ColumnEditable = columnEditable;
    

    % Save the correlations to the app data
    setappdata(f, 'correlations', correlations);
    setappdata(f, 'variable_names', data_table.Properties.VariableNames);
    
    % Enable buttons
    graph_button.Enable = 'on';      
    sort_button.Enable = 'on';
    sort_path_button.Enable = 'on';
    cluster_button.Enable = 'on'; 
    single_to_group_button.Enable = 'on'; % Initially disabled
    single_to_path_button.Enable = 'on';

    f.WindowStyle = 'normal';
%     uifigureOnTop (f, true)
%     Create a figure for the heatmap
    figure ('Position',[100 300 400 400])
    histogram (correlations)
    title('Correlation Histogram');
    xlabel('Pairwise Correleation Coefficient, q');
    ylabel('Number of genes');

%   Create a figure for the heatmap
    
    figure("Position",[100,100, 400,400]);
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
    figure("Position",[800,100, 400,400]);
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
%     uifigureOnTop (f, true)
    % Get the correlations and variable names from the app data
    correlations = getappdata(f, 'correlations');
    variable_names = getappdata(f, 'variable_names');

 %% Option 1: Select random genes (uncomment when needed)
%     random_indices = randperm(length(variable_names), 50); % put any nubmer instead of 50
%     correlations = correlations(random_indices, random_indices);
%     variable_names = variable_names(random_indices);


% % Option 2: Prompt user to select a text file with genes (uncomment when needed)
% [file_name, path_name] = uigetfile('*.txt', 'Select a text file containing gene names');
% if isequal(file_name, 0)
%     disp('User selected Cancel');
%     return;
% else
%     % Read gene names from the selected file
%     file_path = fullfile(path_name, file_name);
%     selected_genes = textread(file_path, '%s');
%     
%     % Convert both lists of genes to lowercase for case-insensitive matching
%     selected_genes_lower = lower(selected_genes);
%     variable_names_lower = lower(variable_names2);
%     
%     % Match these genes with variable_names to get indices
%     [~, indices] = ismember(selected_genes_lower, variable_names_lower);
%     
%     % Filter out non-matching genes (indices == 0)
%     valid_indices = indices(indices > 0);
%     
%     correlations = correlations2(valid_indices, valid_indices);
%     variable_names = variable_names2(valid_indices);
% end
% -----------------------
%     
    % Calculate the sum of absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices);  % Also sort the sum of absolute correlations
    %% Global
     % Calculate the sum of global absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices); 
    
     % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
    
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = sorted_correlations;
    data.ColumnName = sorted_variable_names;
    data.RowName = sorted_variable_names;

    % Save the sorted correlations and variable names to the app data
    setappdata(f, 'sorted_correlations', sorted_correlations);
    setappdata(f, 'sorted_variable_names', sorted_variable_names);

    % Set the results in the GUI
    f.Name = ['Sorted Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];

  % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
  % Create a new uifigure for the sorted data

% Modify the title of uifigure to include the file_name
% sorted_fig = uifigure('Name', ['List of Correlated Genes from ' file_name ' (Pathway Correlation Index: ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');

if exist('file_name', 'var') && ~isempty(file_name)
    title_str = ['List of Correlated Genes from ' file_name];
else
    title_str = 'List of Correlated Genes';
end

sorted_fig = uifigure('Name', [title_str ' (PCI-Global: ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');

% Create a uitable in the new uifigure
sorted_data = uitable(sorted_fig);


%% Global
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

%% Experiment
% indices = find(top_variable_names' == 'Chtf8');
% Find indices of elements that match the value

%%
setappdata(0,'cor_variable',top_variable_names')
setappdata(0,'cor_value',average_abs_correlation)
% Enable sorting for the first column (Gene)
sorted_data.ColumnSortable(1) = true;

% Enable sorting for the second column (Average Absolute Correlations)
sorted_data.ColumnSortable(2) = true;
    
end

function sort_path_callback(~, ~, f)
    f.WindowStyle = 'normal';
%     uifigureOnTop (f, true)
    % Get the correlations and variable names from the app data
    correlations2 = getappdata(f, 'correlations');
    variable_names2 = getappdata(f, 'variable_names');

% Option 2: Prompt user to select a text file with genes (uncomment when needed)
[file_name, path_name] = uigetfile('*.txt', 'Select a text file containing gene names');
if isequal(file_name, 0)
    disp('User selected Cancel');
    return;
else
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
    
    correlations = correlations2(valid_indices, valid_indices);
    variable_names = variable_names2(valid_indices);
end
% -----------------------
%     
    % Calculate the sum of absolute correlations for each variable (gene)   
    sum_abs_correlations = sum(abs(correlations), 2) - 1; % Subtract 1 for self-correlation
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    sorted_sum_abs_correlations = sum_abs_correlations(sorted_indices);  % Also sort the sum of absolute correlations
    %% Global
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
    f.Name = ['Sorted Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];

  % List of average correlations
    total_genes = sqrt(numel(correlations));
    top_variable_names = sorted_variable_names(1:total_genes);
    top_sum_abs_correlations = sorted_sum_abs_correlations(1:total_genes); 
 
  % Adjust calculation for average absolute correlation after excluding self-correlation 
    average_abs_correlation = top_sum_abs_correlations / (total_genes - 1);
    mean_average_abs_correlation = sum(average_abs_correlation)/total_genes;
  % Create a new uifigure for the sorted data

% Modify the title of uifigure to include the file_name
% sorted_fig = uifigure('Name', ['List of Correlated Genes from ' file_name ' (Pathway Correlation Index: ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');

if exist('file_name', 'var') && ~isempty(file_name)
    title_str = ['List of Correlated Genes from ' file_name];
else
    title_str = 'List of Correlated Genes from Random';
end

modified_title = [title_str ' PCI (A)=' num2str(mean_average_abs_correlation) ', PCI (B)='  ')'];
% sorted_fig = uifigure('Name', [title_str ' (PCI from the Pathway): ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
sorted_fig = uifigure('Name', modified_title, 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
% Create a uitable in the new uifigure
sorted_data = uitable(sorted_fig);


%% Global
array=[];
 for j =1:length(sorted_correlations)
        
%%
        var= top_variable_names2';
        matching_indices = find(cellfun(@(x) isequal(x, sorted_variable_names{j}), var));
        cor= average_abs_correlation2;
        array{j}= cor(matching_indices);
        
 end
 % Display gene correlations in the new uitable
sorted_data.Data = [top_variable_names', num2cell(average_abs_correlation),array'];  % Add sum of absolute correlations to the table
sorted_data.ColumnName = {'Gene', 'A: Correlation within the Pathway','B: Correlation Extracted from Global'};  % Update column names
sorted_data.Position = [20 20 560 360];  

%% Experiment
% indices = find(top_variable_names' == 'Chtf8');
% Find indices of elements that match the value

%%
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
    correlations = getappdata(f, 'correlations');
    variable_names = getappdata(f, 'variable_names');

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
%     uifigureOnTop (f, false)

    answer = inputdlg_id(prompt, title, dims, definput);
    colorThreshold = str2double(answer{1}); % convert string to number

    % Create a dendrogram
    folder = fileparts(mfilename('fullpath'));
    iconFilePath = fullfile(folder, 'Images', 'Corr_icon.png');
    setIcon(figure, iconFilePath)
    
    [H,T,outperm] = dendrogram(links, 0, 'Orientation','top', 'Reorder',cluster_order, 'colorThreshold', colorThreshold); % Create a dendrogram
    set(H, 'LineWidth', 1);  % Set to desired line width
    ylabel('Distance')

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
    f.Name = ['Clustered Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];
    
    % Enable the "Graph" button
    graph_button.Enable = 'on';
    elbow_button.Enable = 'on';
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
        
%%
        var= getappdata(0,'cor_variable');
        matching_indices = find(cellfun(@(x) isequal(x, variables_in_cluster{j}), var));
        cor= getappdata(0,'cor_value');
        sum_cor=sum_cor+abs(cor(matching_indices));
    end
    cluster_info{i, 3} = sum_cor/length(variables_in_cluster);
end

% Create a new uifigure to display cluster information
cluster_info_fig = uifigure('Name', 'Cluster Information', 'Position', [800, 250, 400, 300]);
cluster_info_table = uitable(cluster_info_fig);
cluster_info_table.Data = cluster_info;
cluster_info_table.ColumnName = {'Cluster Number', 'Number of Genes','PCI','Gene Names'};
cluster_info_table.Position = [20, 20, 360, 260];
% setappdata(0,'cor_variable',top_variable_names')
% setappdata(0,'cor_value',average_abs_correlation)

% Enable sorting for the first column (cluster number)
cluster_info_table.ColumnSortable(1) = true;

% Enable sorting for the second column (number of genes)
cluster_info_table.ColumnSortable(2) = true;


% Enable sorting for the second column (Index)
cluster_info_table.ColumnSortable(3) = true;
end

%% Define the "Elbow Curve" and Silhouette callback functions
function elbow_curve_callback(~, ~, f)
    correlations = getappdata(f, 'correlations');  % Get correlations from app data
    maxK = 30;  % Maximum number of clusters to check
    sum_of_squared_distances = zeros(maxK, 1);
    silhouette_vals = zeros(maxK-1, 1);  % No silhouette for K = 1
    
    for k = 1:maxK
        [idx, ~, sumD] = kmeans(correlations, k);
        sum_of_squared_distances(k) = sum(sumD);
    end    
   
    for k = 2:maxK  % Start from 2 clusters
        [idx, ~] = kmedoids(correlations, k);
        
        % Compute silhouette values for this cluster count
        s = silhouette(correlations, idx, 'sqEuclidean');
        silhouette_vals(k-1) = mean(s);
    end


% Create a subplot to show both elbow and silhouette plots side by side
    figure;
    
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
end

%% Dynamic_tree_cut function
function dynamic_tree_cut_callback(~, ~, f)
    % Get the correlations from the app data
    correlations = getappdata(f, 'correlations');
    variable_names = getappdata(f, 'variable_names');
    
    % Ask the user to specify cutoff_cl
    prompt = {'Enter cutoff value (default is 0.15):'};
    dlgtitle = 'Cutoff Input';
    dims = [1 35];
    definput = {'0.15'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    % If the user presses Cancel, the answer is empty. Handle this case
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
    figure;
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

%     % Display the number of members in each cluster in the Command Window
%     unique_clusters = unique(T);
%     disp('Cluster Results:');
%     for i = 1:length(unique_clusters)
%         cluster_members = variable_names(T == unique_clusters(i));
%         disp(['Cluster ' num2str(i) ' (Size: ' num2str(length(cluster_members)) '):']);
%         disp(strjoin(cluster_members, ', '));
%     end
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
    figure;

hold on; % Hold on to the current figure
for i = 1:length(single_to_group_correlations)
    if single_to_group_correlations(i) < 0
        bar(i, single_to_group_correlations(i), 'FaceColor', 'r', 'EdgeColor', 'r'); % Negative correlations in red
    else
        bar(i, single_to_group_correlations(i), 'FaceColor', 'b', 'EdgeColor', 'b'); % Positive correlations in default color
    end
end

    % Include the average of the absolute correlations in the title
    title_str = sprintf('Correlation of %s to selected group of genes (Avg. Abs. Corr. = %.2f)', single_gene_name, avg_abs_correlation);
    title(title_str);
    
    ylabel('Correlation Coefficient');
    xticks(1:length(group_gene_names));
    xticklabels(group_gene_names);
    xtickangle(45); % Angle the labels for readability
    set(gcf, 'Position', [200, 200, 700, 400]); % Set the position of the figure
   
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

    % Display or plot the results
    figure;

% Display or plot the results with color coding

hold on; % Hold on to the current figure
for i = 1:length(single_to_pathway_correlations)
    if single_to_pathway_correlations(i) < 0
        bar(i, single_to_pathway_correlations(i), 'FaceColor', 'r', 'EdgeColor', 'r'); % Negative correlations in red
    else
        bar(i, single_to_pathway_correlations(i), 'FaceColor', 'b', 'EdgeColor', 'b'); % Positive correlations in default color
    end
end
hold off; % Release the figure

% Include the file name and the average of the absolute correlations in the title
title_str = sprintf('Correlation of %s to pathway genes in %s (Avg. Abs. Corr. = %.2f)', single_gene_name, file, avg_abs_correlation);
title(title_str);

ylabel('Correlation Coefficient');
xticks(1:length(genes_list));
xticklabels(genes_list);
xtickangle(45); % Angle the labels for readability
set(gcf, 'Position', [200, 200, 700, 400]); % Set the position of the figure

end


end



