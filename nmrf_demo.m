% 
% NMF could help you identify clusters or latent factors that reveal how
% groups of genes are commonly regulated in response to oxaliplatin
% treatment.
% 
% Here’s how this could provide insights into mechanisms:
% 
% Clusters of Genes (Basis Matrix 𝑊 W):
% 
% By decomposing the data, NMF can reveal clusters of genes that tend to be
% co-expressed (or have similar LSmean levels) across the two groups. This
% could point to groups of genes or pathways that are differentially
% regulated in response to oxaliplatin, possibly identifying key pathways
% impacted by the treatment. 
% 
% Clusters of Mice (Loading Matrix 𝐻 H):
% 
% The loading matrix 𝐻 H would indicate how each mouse aligns with each
% identified gene cluster. Mice treated with oxaliplatin might load more
% strongly onto certain clusters, reflecting a shared transcriptional
% response pattern, while control mice might align with different clusters.

% Interpreting the Mechanism:
% 
% Once clusters of genes are identified, you could use pathway enrichment
% analysis or gene ontology (GO) analysis to interpret the biological
% processes or pathways these clusters represent. For example, a cluster
% enriched in genes related to DNA repair, apoptosis, or cell cycle
% regulation might suggest that oxaliplatin impacts these mechanisms.
% 
% 

% Open a file selection dialog for the user to select an Excel file
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

% Set the number of latent factors (clusters) to extract
k = 2; % Adjust based on the complexity of your data

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
% This heatmap shows how each mouse associates with each gene cluster

% Heatmap for the loading matrix H (Clusters of Mice)
figure;
heatmap(H, 'Colormap', parula);
title('Heatmap of Loading Matrix (H): Gene Association with Latent Factors');
xlabel('Latent Factors');
ylabel('Genes');
colorbar;
% This heatmap shows how each gene aligns with the identified latent factors

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
% set(gca, 'XTickLabel', geneNames);
legend(arrayfun(@(x) ['Cluster ', num2str(x)], 1:k, 'UniformOutput', false));

% Display the top 10 genes with the highest loading coefficients for each cluster
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
    
    % Optional: Plot the top 10 genes for the current cluster
    figure;
    bar(gene_loadings(top_gene_indices));
    set(gca, 'XTickLabel', geneNames(top_gene_indices), 'XTickLabelRotation', 45);
 
    title(['Top 10 Genes for Cluster ', num2str(cluster)]);
    xlabel('Gene');
    ylabel('Loading Coefficient');
end
