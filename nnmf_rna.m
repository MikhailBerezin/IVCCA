% Berezin Lab, Washington Univerity in St. Louis, 2024

% This function is based of non negative matrix factorization identify clusters or latent factors that reveal how
% groups of genes are commonly regulated in response to oxaliplatin 
% treatment.
% 
% The input requires a matrix samples by genes: DRG 91 genes FDR 0.05 FC more or equal 2 sorted.xls 
%  
% Clusters of Genes (Basis Matrix 𝑊):
% 
% By decomposing the data, the function reveals clusters of genes that tend to be
% co-expressed (or have similar LSmean levels) across the two groups. This
% could point to groups of genes or pathways that are differentially
% regulated in response to oxaliplatin, possibly identifying key pathways
% impacted by the treatment. 
% 
% Clusters of Mice (Loading Matrix 𝐻 ):
% 
% The loading matrix 𝐻 would indicate how each mouse aligns with each
% identified gene cluster. Mice treated with oxaliplatin might load more
% strongly onto certain clusters, reflecting a shared transcriptional
% response pattern, while control mice might align with different clusters.

% Interpreting the Mechanism:
% 
% Once clusters of genes are identified, you can use pathway enrichment
% analysis or gene ontology (GO) analysis to interpret the biological
% processes or pathways these clusters represent. A cluster
% enriched in genes related to DNA repair, apoptosis, or cell cycle
% regulation might suggest that the treatment impacts these mechanisms.
% 
% 

% Open a file selection dialog to select an Excel file
[file, path] = uigetfile('*.xlsx', 'Select the Excel file with gene expression data');
if isequal(file, 0)
    disp('No file selected. Exiting...');
    return;
else
    filename = fullfile(path, file);
    disp(['User selected file: ', filename]);
end

% Load the data from the selected Excel file, including headers
dataTable = readtable(filename);

% Extract gene names from the first row (assumes gene names are in the first row)
geneNames = dataTable.Properties.VariableNames(2:end); % Skips the first column if it contains sample identifiers

% Remove underscores from gene names
geneNames = strrep(geneNames, '_', '');

% Remove the first column and the first row if they contain headers and identifiers
data = table2array(dataTable(:, 2:end)); % Convert to a matrix for NMF, starting from the second column

% Enter for the number of clusters using a popup window
clusterInput = inputdlg('Enter the number of clusters:', ...
                        'Number of Clusters', [1 35], {'2'});

% Validate user input
if isempty(clusterInput) % User pressed Cancel
    disp('No input provided. Using default value of 2 clusters.');
    k = 2;
else
    k = str2double(clusterInput{1}); % Convert user input to a number
    if isnan(k) || k <= 0
        disp('Invalid input. Using default value of 2 clusters.');
        k = 2;
    end
end
disp(['Number of clusters selected: ', num2str(k)]);

% Perform NMF using MATLAB's built-in `nnmf` function
[W, H] = nnmf(data, k);

% Display the factorized matrices
disp('Basis matrix (W):');
disp(W);

disp('Loading matrix (H):');
disp(H);

% Heatmap for the basis matrix W (Clusters of Genes)
figure;
heatmap(W, 'Colormap', parula);
title('Heatmap of Basis Matrix (W): Clusters of Genes');
xlabel('Latent Factors (Gene Clusters)');
ylabel('Mice (Samples)');
colorbar;

% Heatmap for the loading matrix H (Clusters of Mice)
figure;
heatmap(H, 'Colormap', parula);
title('Heatmap of Loading Matrix (H): Gene Association with Latent Factors');
xlabel('Latent Factors');
ylabel('Genes');
colorbar;

% Plot the basis matrix W to show treatment association with clusters
figure;
bar(W);
title('Basis Matrix (W): Treatment Association with Latent Factors');
xlabel('Mice Individual');
ylabel('Association Strength');
legend(arrayfun(@(x) ['Cluster ', num2str(x)], 1:k, 'UniformOutput', false));

% Plot the loading matrix H to show gene association with clusters
figure;
bar(H');
title('Loading Matrix (H): Gene Association with Latent Factors');
xlabel('Gene');
ylabel('Loading Coefficient');
legend(arrayfun(@(x) ['Cluster ', num2str(x)], 1:k, 'UniformOutput', false));

% Display the top genes with the highest loading coefficients for each cluster
for cluster = 1:k
    % Get the loading coefficients for the current cluster
    gene_loadings = H(cluster, :);
    
    % Sort the loadings and get the indices of the top 10 genes
    [~, top_gene_indices] = maxk(gene_loadings, 10);
    
    % Display the top 10 genes and their loading coefficients
    disp(['Top 10 genes for Cluster ', num2str(cluster), ':']);
    for i = 1:length(top_gene_indices)
        gene_index = top_gene_indices(i);
        disp(['Gene ', geneNames{gene_index}, ': Loading Coefficient = ', num2str(gene_loadings(gene_index))]);
    end
    
    % Plot the top 10 genes for the current cluster
    figure;
    bar(gene_loadings(top_gene_indices));
    set(gca, 'XTickLabel', geneNames(top_gene_indices), 'XTickLabelRotation', 45);
    title(['Top 10 Genes for Cluster ', num2str(cluster)]);
    xlabel('Gene');
    ylabel('Loading Coefficient');
end

