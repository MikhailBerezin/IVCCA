function calculate_pathways_correlation_callback2(~, ~, f)

 % Find all open message boxes and close them
    msgBoxes = findall(0, 'Type', 'figure', 'Tag', 'msgbox');
    delete(msgBoxes);

width = 250;
height = 75;
% Initialize a persistent variable to store the last used directory
persistent lastUsedDir;
if isempty(lastUsedDir)
    lastUsedDir = pwd; % Set to current directory if not previously set
end

% Create a popup dialog to select pathway 1 data file
[filename1, pathname1] = uigetfile([lastUsedDir, '/*.txt'], 'Select pathway 1 data file');

% Check if the user canceled file selection
if isequal(filename1, 0)
    disp('File selection canceled.');
    return;
else
    lastUsedDir = pathname1; % Update the last used directory
end

% Create a popup dialog to select pathway 2 data file
[filename2, pathname2] = uigetfile([lastUsedDir, '/*.txt'], 'Select pathway 2 data file');

% Check if the user canceled file selection
if isequal(filename2, 0)
    disp('File selection canceled.');
    return;
else
    lastUsedDir = pathname2; % Update the last used directory
end


  % Read data from the selected text files
%     pathway1_data = textread(fullfile(pathname1, filename1), '%f');
    file_path = fullfile(pathname1, filename1);
    pathway1_genes = textread(file_path, '%s');
%     pathway2_data = textread(fullfile(pathname2, filename2), '%f');
    file_path2 = fullfile(pathname2, filename2);
    pathway2_genes = textread(file_path2, '%s');

  
    % Initialize an empty array to store absolute correlation coefficients
    abs_correlation_coeffs = [];
    
    %%
    data=  getappdata(0, 'correlations');
    geneNames= getappdata(0,'variable_names');
    %%
   
      k=1;
      l=1;
      
% Initialize empty cell arrays for storing filtered gene names
pathway_genes_1 = {};
pathway_genes_2 = {};

% Populate pathway_genes_1
for i = 1:length(pathway1_genes)
    rowNameToFind = pathway1_genes{i};
    rowIndex = find(strcmp(geneNames, rowNameToFind));
    if ~isempty(rowIndex)
        pathway_genes_1{k} = rowNameToFind;
        k = k + 1;
    end
end

% Populate pathway_genes_2
for j = 1:length(pathway2_genes)
    columnNameToFind = pathway2_genes{j};
    columnIndex = find(strcmp(geneNames, columnNameToFind));
    if ~isempty(columnIndex)
        pathway_genes_2{l} = columnNameToFind;
        l = l + 1;
    end
end

% Check if either pathway_genes_1 or pathway_genes_2 is empty
if isempty(pathway_genes_1) || isempty(pathway_genes_2)
    h1 = msgbox('One or more of the selected pathways have no genes found in the data. Stopping further calculations.');
    set(h1, 'Position', [200 300 width*1.3 height])
    return;
end

    for i = 1:length(pathway_genes_1)
        
        for j = 1:length(pathway_genes_2)

            rowNameToFind = pathway_genes_1{i};  % Replace with the actual row name
            rowIndex = find(strcmp(geneNames, rowNameToFind));

            % Find the column index based on the column name
            columnNameToFind = pathway_genes_2{j};  % Replace with the actual column name
            columnIndex = find(strcmp(geneNames, columnNameToFind));

            % Check if the row and column indices are found
            if ~isempty(rowIndex) && ~isempty(columnIndex)
                % Get the value at the specified row and column
                cellValue = data(rowIndex, columnIndex);

                % Display the result
                new_data{i,j}=cellValue;
               
                
            else
               
                disp('Row or column not found.');
                
                break
            end
         end
    end

% Check if either pathway_genes_1 or pathway_genes_2 is empty
if isempty(pathway_genes_1) || isempty(pathway_genes_2)
    h2 = msgbox('One or more of the selected pathways have no genes found in the data. Stopping further calculations.');
    set(h2, 'Position', [300 300 width height])
    return;
end

% Find overlapping genes between pathway_genes_1 and pathway_genes_2
overlapping_genes = intersect(pathway_genes_1, pathway_genes_2);


% Calculate the number of overlapping genes
num_overlapping_genes = length(overlapping_genes);

% Check if there are overlapping genes
if isempty(overlapping_genes)
    h3 = msgbox('No overlapping genes found between the two pathways.', 'Genes overlap', 'modal');
    set(h3, 'Position', [300 200 width height])
else
    % Display the overlapping genes and their count
    overlapping_genes_str = strjoin(overlapping_genes, ', ');
   message = {['Number of overlapping genes: ', num2str(num_overlapping_genes)], ...
           ['Overlapping genes: ', overlapping_genes_str]};
   h4 = msgbox(message, 'Overlapping Genes', 'non-modal');
   set(h4, 'Position', [300 200 width height])
end

% Exclude overlapping genes from pathway_genes_1 and pathway_genes_2
pathway_genes_1 = setdiff(pathway_genes_1, overlapping_genes);
pathway_genes_2 = setdiff(pathway_genes_2, overlapping_genes);

% Calculate the total number of genes in both pathways
total_genes = length(pathway_genes_1) + length(pathway_genes_2) + num_overlapping_genes;
if num_overlapping_genes == total_genes
    % All genes overlap, cosine similarity is 1
   h5 = msgbox('All genes in both pathways overlap. Cosine similarity index is 1.', ...
           'Cosine Similarity', 'non-modal');
   set(h5, 'Position', [300 100 width height])
    return
end

% Check if either pathway_genes_1 or pathway_genes_2 is empty after
% no genes overlap, cosine similarity is 1
if isempty(pathway_genes_1) || isempty(pathway_genes_2)
  h6 =  msgbox('No unique genes found for comparison after excluding overlapping genes.Cosine similarity index is 0');
  set(h6, 'Position', [300 200 width height])
    return;
end

% Initialize new_data for the table
new_data = cell(length(pathway_genes_1), length(pathway_genes_2));

    % Variables for cosine similarity calculation
    dot_product = 0;
    norm_set1 = 0;
    norm_set2 = 0;


 % Loop through the non-overlapping genes to fill in new_data and calculate cosine similarity
    for i = 1:length(pathway_genes_1)
        for j = 1:length(pathway_genes_2)
            rowNameToFind = pathway_genes_1{i}; 
            rowIndex = find(strcmp(geneNames, rowNameToFind));

            columnNameToFind = pathway_genes_2{j}; 
            columnIndex = find(strcmp(geneNames, columnNameToFind));

            if ~isempty(rowIndex) && ~isempty(columnIndex)
                cellValue = data(rowIndex, columnIndex);
                new_data{i,j} = cellValue;
                
                % Update values for cosine similarity
                dot_product = dot_product + cellValue^2;
                norm_set1 = norm_set1 + 1;
                norm_set2 = norm_set2 + 1;
            end
        end
    end

    % Include overlapping genes in the cosine similarity calculation
    for i = 1:num_overlapping_genes
        dot_product = dot_product + 1; % Add 1 for each overlapping gene
        norm_set1 = norm_set1 + 1;
        norm_set2 = norm_set2 + 1;
    end

    % Calculate cosine similarity
    if norm_set1 ~= 0 && norm_set2 ~= 0
        cosine_similarity = dot_product / (sqrt(norm_set1) * sqrt(norm_set2));
    else
        cosine_similarity = NaN; % Handle case where there are no valid entries
    end

% Add overlapped genes (correlation of 1) to the cosine similarity
    adjusted_cosine_similarity = (cosine_similarity + num_overlapping_genes) / (num_overlapping_genes + 1);


    modified_title = 'Compare pathways: Pathway 1 in column, Pathway 2 in row';
% sorted_fig = uifigure('Name', [title_str ' (PCI from the Pathway): ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
sorted_fig = uifigure('Name', modified_title, 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png', 'Visible', 'on');
% Create a uitable in the new uifigure
sorted_data = uitable(sorted_fig);
 % Display gene correlations in the new uitable
sorted_data.Data = new_data;  % Add sum of absolute correlations to the table
sorted_data.ColumnName = pathway_genes_2;
sorted_data.RowName = pathway_genes_1;  % Update column names
sorted_data.Position = [20 20 560 360];  

%     Calculate the average absolute correlation
    average_abs_correlation = mean(abs_correlation_coeffs);

    fprintf('Average Absolute Pairwise Correlation: %.4f\n', average_abs_correlation);


% Initialize variables for calculating the average
totalValue = 0;
count = 0;

% Loop through new_data to accumulate values and count valid entries
for i = 1:size(new_data, 1)
    for j = 1:size(new_data, 2)
        if ~isempty(new_data{i,j})
            totalValue = totalValue + abs(new_data{i,j});
            count = count + 1;
        end
    end
end

 h7 =   msgbox(['Cosine similarity index between two pathways: ', num2str(adjusted_cosine_similarity)], ...
           'Cosine Similarity', 'non-modal');
%  h7 =   msgbox(['Cosine similarity index between two pathways: ', num2str(cosine_similarity)], ...
%            'Cosine Similarity', 'non-modal');
    
 set(h7, 'Position', [300 300 width height])
end
