function calculate_pathways_correlation_callback(~, ~, f)
   

% Create a popup dialog to select pathway 1 data file
[filename1, pathname1] = uigetfile('*.txt', 'Select pathway 1 data file');

% Check if the user canceled file selection
if isequal(filename1, 0)
    disp('File selection canceled.');
    return;
end

% Create a popup dialog to select pathway 2 data file
[filename2, pathname2] = uigetfile('*.txt', 'Select pathway 2 data file');

% Check if the user canceled file selection
if isequal(filename2, 0)
    disp('File selection canceled.');
    return;
end

  % Read data from the selected text files
%     pathway1_data = textread(fullfile(pathname1, filename1), '%f');
    file_path = fullfile(pathname1, filename1);
    pathway1_genes = textread(file_path, '%s');
%     pathway2_data = textread(fullfile(pathname2, filename2), '%f');
    file_path2 = fullfile(pathname2, filename2);
    pathway2_genes = textread(file_path2, '%s');

    % Assuming each gene has 'num_measurements' measurements
    num_measurements = 10;  % extract this number from the data 

    % Calculate the number of genes in each pathway
%     num_genes_pathway1 = length(pathway1_data) ;
%     num_genes_pathway2 = length(pathway2_data) ;
% 
%     % Reshape the data into cell arrays for each gene in each pathway
%     pathway1_genes = mat2cell(pathway1_data, repmat(num_measurements, num_genes_pathway1, 1), 1);
%     pathway2_genes = mat2cell(pathway2_data, repmat(num_measurements, num_genes_pathway2, 1), 1);

    % Initialize an empty array to store absolute correlation coefficients
    abs_correlation_coeffs = [];
    
    %%
    data=  getappdata(0, 'correlations');
    geneNames= getappdata(0,'variable_names');
    %%
   
% %     matchingNames = geneNames(strcmp(geneNames, pathway1_genes));
%     matchingIndices1 = contains(geneNames, pathway1_genes);
% 
% % Use logical indexing to get matching names
%     pathway1_genes = geneNames(matchingIndices1);
%     
%     % Calculate pairwise correlations and take absolute values
%       matchingIndices2 = contains(geneNames, pathway2_genes);
% 
% % Use logical indexing to get matching names
%       pathway2_genes = geneNames(matchingIndices2);
      
      k=1;
      l=1;
      
       for i = 1:length(pathway1_genes)
           rowNameToFind = pathway1_genes{i};  % Replace with the actual row name
            rowIndex = find(strcmp(geneNames, rowNameToFind));
               if ~isempty(rowIndex)
                % Get the value at the specified row and column
                
                pathway_genes_1{k}=rowNameToFind;
                k=k+1;
               end
       end   
        
        for j = 1:length(pathway2_genes)
%             correlation_coeff = corr(pathway1_genes{i}, pathway2_genes{j});
%             abs_correlation_coeffs = [abs_correlation_coeffs; abs(correlation_coeff)];
       
            % Find the column index based on the column name
            columnNameToFind = pathway2_genes{j};  % Replace with the actual column name
            columnIndex = find(strcmp(geneNames, columnNameToFind));

            
            if ~isempty(columnIndex)
                 
                pathway_genes_2{l}=columnNameToFind;
                l=l+1;
            end
                
           
         end
    
    for i = 1:length(pathway_genes_1)
        
        for j = 1:length(pathway_genes_2)
%             correlation_coeff = corr(pathway1_genes{i}, pathway2_genes{j});
%             abs_correlation_coeffs = [abs_correlation_coeffs; abs(correlation_coeff)];
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
    modified_title = 'Compare tab';
% sorted_fig = uifigure('Name', [title_str ' (PCI from the Pathway): ' num2str(mean_average_abs_correlation) ')'], 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
sorted_fig = uifigure('Name', modified_title, 'Position', [600 250 600 400], 'Icon', 'Corr_icon.png');
% Create a uitable in the new uifigure
sorted_data = uitable(sorted_fig);
 % Display gene correlations in the new uitable
sorted_data.Data = new_data;  % Add sum of absolute correlations to the table
sorted_data.ColumnName = pathway_genes_2;
sorted_data.RowName = pathway_genes_1;  % Update column names
sorted_data.Position = [20 20 560 360];  
    % Calculate the average absolute correlation
%     average_abs_correlation = mean(abs_correlation_coeffs);
% 
%     fprintf('Average Absolute Pairwise Correlation: %.4f\n', average_abs_correlation);
end