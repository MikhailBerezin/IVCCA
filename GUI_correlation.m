function GUI_correlation
% Mikhail Berezin 2023
f = uifigure('Name', 'Correlation Analysis (Berezin Lab)', 'Position', [200 200 600 400], 'Icon','neurites.png');  % adjusted width

% f.WindowStyle = 'normal';
% uifigureOnTop (f, true) 

% Create the grid layout
grid = uigridlayout(f, [5 2], 'ColumnWidth', {'1x', '0.2x'}, 'RowHeight', {'1x', '1x', '1x', '1x', '1x'});  % now 4x2 grid, second column smaller

% Create the uitable
data = uitable(grid, 'ColumnEditable', true);
data.Layout.Row = [1 5]; % Spans across 5 rows
data.Layout.Column = 1; % Occupies the first column

% Create the "Load Data" button
load_button = uibutton(grid, 'push', 'Text', 'Load Data', 'ButtonPushedFcn', {@load_data_callback, f});
load_button.Layout.Row = 1; % Position for "Load Data" button
load_button.Layout.Column = 2; 
load_button.Tooltip = 'load the excel or csv data';  % Adding tooltip

% Create the "Calculate Correlations" button
calculate_button = uibutton(grid, 'push', 'Text', 'Calculate', 'ButtonPushedFcn', {@calculate_correlations_callback, f});
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

% Create the "Graph" button
graph_button = uibutton(grid, 'push', 'Text', 'Graph', 'ButtonPushedFcn', {@graph_callback, f});
graph_button.Layout.Row = 4; % Position for "Graph" button
graph_button.Layout.Column = 2;
graph_button.Tooltip = 'Graph the correlation matrix or sorted correlation matrix';  % Adding tooltip
graph_button.Enable = 'off'; % Initially disabled

% Create the "Cluster" button
cluster_button = uibutton(grid, 'push', 'Text', 'Cluster', 'ButtonPushedFcn', {@cluster_callback, f});
cluster_button.Layout.Row = 5; % Position for "Cluster" button
cluster_button.Layout.Column = 2;
cluster_button.Tooltip = 'Cluster the correlation matrix';  % Adding tooltip
cluster_button.Enable = 'off'; % Initially disabled

% Create the results label
result = uilabel(grid, 'Text', '');
result.Layout.Row = 4; % Position for label
result.Layout.Column = 1; % Positioned in the first column

%% This fucntion removes the rows with missing numbers
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
    data_table(1, :) = [];

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
    uifigureOnTop (f, true) 
end





%% This function replace the missing values
% function load_data_callback(~, ~, f)
%     % Get the file name
%     [file, path] = uigetfile('*.xlsx', 'Select a data file');
%     if isequal(file, 0)
%         return
%     end
%     
%     % Read the data from the file
%     try
%         data_table = readtable(fullfile(path, file));
%     catch
%         errordlg('Error reading data. Please check the format of the data file.');
%         return
%     end
%     
%     % Ignore the first row
%     data_table(1, :) = [];
% 
%     % Check that the data table has at least two columns
%     if size(data_table, 2) < 2
%         errordlg('Data file must have at least two columns.');
%         return
%     end
%     
%     % Handle missing data by replacing NaN values with the mean of each column
%     % varfun adds 'fun_' to column names, to avoid it we will store original column names and assign them back
%     originalVariableNames = data_table.Properties.VariableNames;
%     data_table = varfun(@(x) fillmissing(x, 'constant', mean(x, 'omitnan')), data_table, 'OutputFormat', 'table');
%     data_table.Properties.VariableNames = originalVariableNames;
%     
%     % Set the data table in the GUI
%     data.Data = data_table;
%     calculate_button.Enable = 'on'; % Enable the "Calculate Correlations" button
%     
%     % Display the loaded data in the Command Window
%     disp(data_table);
%     
%     % Save the data table to the app data
%     setappdata(f, 'data_table', data_table);
% end



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
    correlations = corrcoef(table2array(data_table));

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
    
    % Enable the "Graph" button
    graph_button.Enable = 'on';
    
    % Enable the "Sort" and "Cluster' button
    sort_button.Enable = 'on';
    cluster_button.Enable = 'on'; 

    f.WindowStyle = 'normal';
    uifigureOnTop (f, true)

    % Create a new figure for the heatmap
    figure;
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
    uifigureOnTop (f, true)
    % Get the sorted correlations and variable names from the app data
    correlations = getappdata(f, 'sorted_correlations');
    variable_names = getappdata(f, 'sorted_variable_names');

    % Remove the upper triangle of the matrix
    correlations = tril(correlations);

    % Convert all numbers to absolute values
    correlations = abs(correlations);

    % Create a new figure for the heatmap
    folder = fileparts(mfilename('fullpath'));
    iconFilePath = fullfile(folder, 'Images', 'idcube-icon-transparent.png');
    setIcon(figure, iconFilePath)
    h = imagesc(correlations); % Create a heatmap
    colorbar; % Add a colorbar

    % Modify colormap
    cm = jet(256); % Create jet colormap
    cm(1,:) = [0.5 0.5 0.5]; % Change the first color (for zero values) to grey
    colormap(cm); % Apply the modified colormap

    title('Correlation Heatmap');
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
%     
%     % Set color of zero values to grey
%     h.CDataMapping = 'scaled'; 
%     caxis([-1 1]); 
end





%% Define the "Sort" callback function

function sort_callback(~, ~, f)
    f.WindowStyle = 'normal';
    uifigureOnTop (f, true)
    % Get the correlations and variable names from the app data
    correlations = getappdata(f, 'correlations');
    variable_names = getappdata(f, 'variable_names');
    
    % Calculate the sum of absolute correlations for each variable
    sum_abs_correlations = sum(abs(correlations), 2);
    
    % Sort the sums in descending order and get the indices
    [~, sorted_indices] = sort(sum_abs_correlations, 'descend');
    
    % Use the sorted indices to sort the correlations and variable names
    sorted_correlations = correlations(sorted_indices, sorted_indices);
    sorted_variable_names = variable_names(sorted_indices);
    
    % Update the data in the existing uitable instead of creating a new one
    data.Data = sorted_correlations;
    data.ColumnName = sorted_variable_names;
    data.RowName = sorted_variable_names;

    % Save the sorted correlations and variable names to the app data
    setappdata(f, 'sorted_correlations', sorted_correlations);
    setappdata(f, 'sorted_variable_names', sorted_variable_names);
    
    % Set the results in the GUI
    f.Name = ['Sorted Correlation Matrix: (' num2str(size(correlations, 1)) ' x ' num2str(size(correlations, 2)) ')'];

  % Now, let's keep only the top 100 correlations
   % top_100_correlations = sorted_correlations(1:100);
    top_100_variable_names = sorted_variable_names(1:100);
    
    % Create a new uifigure for the sorted data
    sorted_fig = uifigure('Name', 'Top 100 Correlated Genes', 'Position', [700 300 600 400]);
    
    % Create a uitable in the new uifigure
    sorted_data = uitable(sorted_fig);
    
    % Display the top 100 correlations in the new uitable
%     sorted_data.Data = [top_100_variable_names, num2cell(top_100_correlations)];
    sorted_data.Data = top_100_variable_names;
%     sorted_data.ColumnName = {'Gene Pair', 'Correlation'};
    sorted_data.Position = [20 20 560 360];

end


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
    uifigureOnTop (f, false)

    answer = inputdlg_id(prompt, title, dims, definput);
    colorThreshold = str2double(answer{1}); % convert string to number

    % Create a dendrogram
    folder = fileparts(mfilename('fullpath'));
    iconFilePath = fullfile(folder, 'Images', 'idcube-icon-transparent.png');
    setIcon(figure, iconFilePath)
    [H,T,outperm] = dendrogram(links, 0, 'Orientation','top', 'Reorder',cluster_order, 'colorThreshold', colorThreshold); % Create a dendrogram
    set(H, 'LineWidth', 1);  % Set to desired line width
    ylabel('Distance')
    %     title('Dendrogram');
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

    % Compute the number of clusters at the colorThreshold
    num_clusters_color_threshold = size(links, 1) + 1 - sum(links(:,3) < colorThreshold);

    % Print the number of clusters at the color threshold
    disp(['Number of clusters with unique color: ', num2str(num_clusters_color_threshold)]);
    
    % Assign clusters and extract variable names for each cluster
    cluster_assignments = cluster(links, 'Cutoff', colorThreshold, 'Criterion', 'distance');
    unique_clusters = unique(cluster_assignments);
    for i = 1:length(unique_clusters)
        cluster_num = unique_clusters(i);
        variables_in_cluster = variable_names(cluster_assignments == cluster_num);
        disp(['Variables in cluster ', num2str(cluster_num), ': ', strjoin(variables_in_cluster, ', ')]);
    end

    

    % Figure to display text
    figure_text = figure;
    %ax = axes(figure_text);
    text_str = {};
    
    for i = 1:length(unique_clusters)
        cluster_num = unique_clusters(i);
        variables_in_cluster = variable_names(cluster_assignments == cluster_num);
        text_str{i} = ['Cluster ', num2str(cluster_num), ': ', strjoin(variables_in_cluster, ', ')];
    end
    
    % Create editable text box
    uicontrol(figure_text, 'Style', 'edit', 'String', strjoin(text_str, '\n'), 'Units', 'normalized', 'Position', [0, 0, .3, .3], 'Max', 2, 'HorizontalAlignment', 'left');

% Assign clusters and extract variable names for each cluster
    cluster_assignments = cluster(links, 'Cutoff', colorThreshold, 'Criterion', 'distance');
    unique_clusters = unique(cluster_assignments);
    for i = 1:length(unique_clusters)
        cluster_num = unique_clusters(i);
        variables_in_cluster = variable_names(cluster_assignments == cluster_num);
        disp(['Variables in cluster ', num2str(cluster_num), ': ', strjoin(variables_in_cluster, ', ')]);
    end

    % Append cluster numbers to variable names for the x-axis labels
    variable_names_with_cluster_numbers = cell(size(variable_names));
    for i = 1:length(variable_names)
        cluster_num = cluster_assignments(i);
        variable_names_with_cluster_numbers{i} = [variable_names{i} ' (Cluster ' num2str(cluster_num) ')'];
    end

    % Update the xticklabels with the new variable names
    xticklabels(variable_names_with_cluster_numbers(outperm));


end





end



