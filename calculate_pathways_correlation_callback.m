function calculate_pathways_correlation_callback(~, ~, f)
% Berezin Lab 2023
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
[file_name2, pathname2] = uigetfile([lastUsedDir, '/*.txt'], 'Select pathway 2 data file','MultiSelect', 'on');

% Check if the user canceled file selection
if isequal(file_name2, 0)
    disp('File selection canceled.');
    return;
else
    lastUsedDir = pathname2; % Update the last used directory
end


  % Read data from the selected text files

    file_path = fullfile(pathname1, filename1);
    pathway1_genes = textread(file_path, '%s');

    
    %%
    % Initialize an empty array to store absolute correlation coefficients
    abs_correlation_coeffs = [];
    
    %%
    data=  getappdata(0, 'correlations');
    geneNames= getappdata(0,'variable_names');
    %%
   
      k=1;
      m=1;
      
% Initialize empty cell arrays for storing filtered gene names
pathway_genes_1 = {};
pathway_genes_2 = {};

% Populate pathway_genes_1

tableData = cell(length(file_name2), 4);
for i = 1:length(file_name2)
    file_path = fullfile(pathname2, file_name2{i});
    pathway2_genes = textread(file_path, '%s');
    
    % store the number of genes
    num_genes_in_file = length(pathway2_genes);
    
    for u = 1:length(pathway1_genes)
    rowNameToFind = pathway1_genes{u};
    rowIndex = find(strcmp(geneNames, rowNameToFind));
    if ~isempty(rowIndex)
        pathway_genes_1{k} = rowNameToFind;
        k = k + 1;
    end
   
    end
     k=1;
% Populate pathway_genes_2
        for j = 1:length(pathway2_genes)
            columnNameToFind = pathway2_genes{j};
            columnIndex = find(strcmp(geneNames, columnNameToFind));
            if ~isempty(columnIndex)
                pathway_genes_2{m} = columnNameToFind;
                m = m + 1;
            end
        end
        m=1;
% Check if either pathway_genes_1 or pathway_genes_2 is empty
        if isempty(pathway_genes_1) || isempty(pathway_genes_2)

            tableData{i, 1} = file_name2{i};
            tableData{i, 2} = uint16(num_genes_in_file);
            tableData{i, 3} = 0;  %  num over genes
            tableData{i, 4} = 'N/A'; % overlapping       
            tableData{i, 5} = 0; % cos
            
            pathway_genes_2 = {};
             pathway_genes_1={};
            continue
%             return;
        end

        for l = 1:length(pathway_genes_1)
        
        for j = 1:length(pathway_genes_2)

            rowNameToFind = pathway_genes_1{l};  % Replace with the actual row name
            rowIndex = find(strcmp(geneNames, rowNameToFind));

            % Find the column index based on the column name
            columnNameToFind = pathway_genes_2{j};  % Replace with the actual column name
            columnIndex = find(strcmp(geneNames, columnNameToFind));

            % Check if the row and column indices are found
            if ~isempty(rowIndex) && ~isempty(columnIndex)
                % Get the value at the specified row and column
                cellValue = data(rowIndex, columnIndex);

                % Display the result
                new_data{l,j}=cellValue;
               
                
            else
               
%                 disp('Row or column not found.');
                
                break
            end
         end
    end

        % Check if either pathway_genes_1 or pathway_genes_2 is empty
        if isempty(pathway_genes_1) || isempty(pathway_genes_2)
%             h2 = msgbox('One or more of the selected pathways have no genes found in the data. Stopping further calculations.');
%             set(h2, 'Position', [300 300 width height])

            tableData{i, 1} = file_name2{i};
            tableData{i, 2} = uint16(num_genes_in_file);
            tableData{i, 3} = 0;  %  num over genes
            tableData{i, 4} = 'N/A'; % overlapping       
            tableData{i, 5} = 0; % cos

            pathway_genes_2 = {};
             pathway_genes_1={};
%             continue;
        end

        % Find overlapping genes between pathway_genes_1 and pathway_genes_2
        try
        overlapping_genes = intersect(pathway_genes_1, pathway_genes_2);

        catch
            print(pathway_genes_1)
        end
        % Calculate the number of overlapping genes
        num_overlapping_genes = length(overlapping_genes);

        % Check if there are overlapping genes
        if isempty(overlapping_genes)
            tableData{i, 1} = file_name2{i};
            tableData{i, 2} = uint16(num_genes_in_file);
            tableData{i, 3} = 0;  %  num over genes
            tableData{i, 4} = 'N/A'; % overlapping       
            tableData{i, 5} = 0; % cos            
%             continue

        else
            % Display the overlapping genes and their count
            overlapping_genes_str = strjoin(overlapping_genes, ', ');%            
%             message = {['Number of overlapping genes: ', num2str(num_overlapping_genes)], ...
%                    ['Overlapping genes: ', overlapping_genes_str]};
%            h4 = msgbox(message, 'Overlapping Genes', 'non-modal');
%            set(h4, 'Position', [300 200 width height])

        end

        % Exclude overlapping genes from pathway_genes_1 and pathway_genes_2
        pathway_genes_1 = setdiff(pathway_genes_1, overlapping_genes);
        pathway_genes_2 = setdiff(pathway_genes_2, overlapping_genes);

        % Calculate the total number of genes in both pathways
        total_genes = length(pathway_genes_1) + length(pathway_genes_2) + num_overlapping_genes;
        overlapping_genes_str = strjoin(overlapping_genes, ', ');
        if num_overlapping_genes == total_genes
            % All genes overlap, cosine similarity is 1
%            h5 = msgbox('All genes in both pathways overlap. Cosine similarity index is 1.', ...
%                    'Cosine Similarity', 'non-modal');
%            set(h5, 'Position', [300 100 width height])

            tableData{i, 1} = file_name2{i};
            tableData{i, 2} = uint16(num_genes_in_file);
            tableData{i, 3} = num_overlapping_genes;  %  num over genes
            tableData{i, 4} = overlapping_genes_str; % overlapping
            tableData{i, 5} = 1; % cos
     

            pathway_genes_2 = {};
             pathway_genes_1={};
            continue
        end

        % Check if either pathway_genes_1 or pathway_genes_2 is empty after
        % no genes overlap, cosine similarity is 1
        if isempty(pathway_genes_1) || isempty(pathway_genes_2)
%           h6 =  msgbox('No unique genes found for comparison after excluding overlapping genes.Cosine similarity index is 0');
%           set(h6, 'Position', [300 200 width height])
             pathway_genes_2 = {};
             pathway_genes_1 = {};
            continue;
        end

        % Initialize new_data for the table
        new_data = cell(length(pathway_genes_1), length(pathway_genes_2));

            % Variables for cosine similarity calculation
            dot_product = 0;
            norm_set1 = 0;
            norm_set2 = 0;


         % Loop through the non-overlapping genes to fill in new_data and calculate cosine similarity
            for n = 1:length(pathway_genes_1)
                for j = 1:length(pathway_genes_2)
                    rowNameToFind = pathway_genes_1{n}; 
                    rowIndex = find(strcmp(geneNames, rowNameToFind));

                    columnNameToFind = pathway_genes_2{j}; 
                    columnIndex = find(strcmp(geneNames, columnNameToFind));

                    if ~isempty(rowIndex) && ~isempty(columnIndex)
                        cellValue = data(rowIndex, columnIndex);
                        new_data{n,j} = cellValue;

                        % Update values for cosine similarity
                        dot_product = dot_product + cellValue^2;
                        norm_set1 = norm_set1 + 1;
                        norm_set2 = norm_set2 + 1;
                    end
                end
            end

            % Include overlapping genes in the cosine similarity calculation
            for p = 1:num_overlapping_genes
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
            
            tableData{i, 1} = file_name2{i};
            tableData{i, 2} = uint16(num_genes_in_file);
            tableData{i, 3} = num_overlapping_genes;  %  num over genes
            tableData{i, 4} = overlapping_genes_str; % overlapping       
            tableData{i, 5} = adjusted_cosine_similarity; % cosine             

            pathway_genes_2 = {};
            pathway_genes_1 = {};
end
% figTitle = 'Compare pathways to ';
 figTitle = ['Compare ' filename1 ' to other pathways' ];
% sorted_fig = uifigure('Name', [title_str ' (PCI from the Pathway): ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
% sorted_fig = uifigure('Name', modified_title, 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png', 'Visible', 'on');
% Create a uitable in the new uifigure
fig = uifigure('Position', [50, 200, 1000, 400], 'Name', figTitle, 'Icon','Corr_icon.png');

% Create a uitable in the uifigure with the sorted data
uit = uitable(fig, 'Data', tableData, 'ColumnName', {'Pathway', 'Number of genes in a pathway','Number of overlapping genes','Names of the overlapping genes', 'Cosine similarity' }, 'Position', [20, 20, 950, 360]);

% Set column width to auto
% uit.ColumnWidth = {'auto', 'auto', 'auto', 'auto'};
 uit.ColumnWidth = {250, 150, 150, 150, 150};

% Adding sorting functionality
uit.ColumnSortable = [true, true, true, true, true];

end
