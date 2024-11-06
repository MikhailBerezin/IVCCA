% Open a file selection dialog for the user to select an Excel file
[file, path] = uigetfile('*.xlsx', 'Select the Excel file with phosphoprotein and histone data');
if isequal(file, 0)
    disp('No file selected. Exiting...');
    return;
else
    filename = fullfile(path, file);
    disp(['User selected file: ', filename]);
end

% Load the X matrix (DRG data) and gene names from the first sheet
X_data = readmatrix(filename, 'Sheet', 1); % Load data excluding headers
X_gene_names = readcell(filename, 'Sheet', 1, 'Range', '1:1'); % Load the first row (gene names)
X_sample_names = readcell(filename, 'Sheet', 1, 'Range', 'A2:A10'); % Load the first column (sample names)
X = X_data(1:end, 2:end); % Remove the first row (gene names) and first column (sample identifiers)

% Load the Y matrix (Heart data) and gene names from the second sheet
Y_data = readmatrix(filename, 'Sheet', 2); % Load data excluding headers
Y_gene_names = readcell(filename, 'Sheet', 2, 'Range', '1:1'); % Load the first row (gene names)
Y_sample_names = readcell(filename, 'Sheet', 2, 'Range', 'A2:A10'); % Load the first column (sample names)
Y = Y_data(1:end, 2:end); % Remove the first row (gene names) and first column (sample identifiers)

% Ensure X and Y matrices have the same number of rows (samples)
if size(X, 1) ~= size(Y, 1)
    error('The number of rows in X and Y must be the same.');
end

% Set the number of latent variables (components) for PLSR
numComponents = 2; % Adjust based on data complexity or desired model

% Perform PLSR
[XL, YL, XS, YS, BETA, PCTVAR, MSE, stats] = plsregress(X, Y, numComponents);

% Specify which latent variable to examine (1 for Latent Variable 1)
latentVariable = 1;

% Number of top genes to display
topN = 10;

% Find the genes with the highest absolute loading values for Latent Variable 1 in DRG (X) and Heart (Y)
[~, idx_X] = maxk(abs(XL(:, latentVariable)), topN); % Top genes in DRG (X) matrix
[~, idx_Y] = maxk(abs(YL(:, latentVariable)), topN); % Top genes in Heart (Y) matrix

% Display the percentage of variance explained by each component
disp('Percentage of variance explained by each component in X and Y:');
disp(PCTVAR);

% Visualize the scores for each component
figure;
scatter(XS(:,1), YS(:,1), 'o');
xlabel('X Scores (Latent Variable 1 - DRG)');
ylabel('Y Scores (Latent Variable 1 - Heart)');
title('PLSR: Latent Variable 1 Scores between DRG and Heart');

% Add labels for each point to indicate the sample name from the first column
for i = 1:size(XS, 1)
    text(XS(i,1), YS(i,1), X_sample_names{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% Display top genes with highest loadings for DRG and Heart
disp(['Top ', num2str(topN), ' genes in DRG (X) with highest loadings on Latent Variable ', num2str(latentVariable), ':']);
for i = 1:topN
    disp(['Gene: ', X_gene_names{idx_X(i)}, ', Loading: ', num2str(XL(idx_X(i), latentVariable))]);
end

disp(['Top ', num2str(topN), ' genes in Heart (Y) with highest loadings on Latent Variable ', num2str(latentVariable), ':']);
for i = 1:topN
    disp(['Gene: ', Y_gene_names{idx_Y(i)}, ', Loading: ', num2str(YL(idx_Y(i), latentVariable))]);
end

% Plot loadings for each component with gene names for both DRG (X) and Heart (Y)
figure;

% Plot X Loadings (DRG)
subplot(1, 2, 1);
bar(XL(:, 1:numComponents));
title('X Loadings (DRG)');
xlabel('Genes (DRG)');
ylabel('Loading Coefficient');
legend(arrayfun(@(x) ['Component ', num2str(x)], 1:numComponents, 'UniformOutput', false));
set(gca, 'XTick', 1:length(X_gene_names), 'XTickLabel', X_gene_names, 'XTickLabelRotation', 90); % Add gene names

% Plot Y Loadings (Heart)
subplot(1, 2, 2);
bar(YL(:, 1:numComponents));
title('Y Loadings (Heart)');
xlabel('Genes (Heart)');
ylabel('Loading Coefficient');
legend(arrayfun(@(x) ['Component ', num2str(x)], 1:numComponents, 'UniformOutput', false));
set(gca, 'XTick', 1:length(Y_gene_names), 'XTickLabel', Y_gene_names, 'XTickLabelRotation', 90); % Add gene names
