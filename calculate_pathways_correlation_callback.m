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
    pathway1_data = textread(fullfile(pathname1, filename1), '%f');
    pathway2_data = textread(fullfile(pathname2, filename2), '%f');

    % Assuming each gene has 'num_measurements' measurements
    num_measurements = 10;  % extract this number from the data 

    % Calculate the number of genes in each pathway
    num_genes_pathway1 = length(pathway1_data) / num_measurements;
    num_genes_pathway2 = length(pathway2_data) / num_measurements;

    % Reshape the data into cell arrays for each gene in each pathway
    pathway1_genes = mat2cell(pathway1_data, repmat(num_measurements, num_genes_pathway1, 1), 1);
    pathway2_genes = mat2cell(pathway2_data, repmat(num_measurements, num_genes_pathway2, 1), 1);

    % Initialize an empty array to store absolute correlation coefficients
    abs_correlation_coeffs = [];

    % Calculate pairwise correlations and take absolute values
    for i = 1:length(pathway1_genes)
        for j = 1:length(pathway2_genes)
            correlation_coeff = corr(pathway1_genes{i}, pathway2_genes{j});
            abs_correlation_coeffs = [abs_correlation_coeffs; abs(correlation_coeff)];
        end
    end

    % Calculate the average absolute correlation
    average_abs_correlation = mean(abs_correlation_coeffs);

    fprintf('Average Absolute Pairwise Correlation: %.4f\n', average_abs_correlation);
end