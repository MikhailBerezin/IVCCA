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

% Define the range for the number of clusters (latent factors) to test
kRange = 2:10; % Adjust as needed
numTrials = 25; % Number of trials to average over
errors = zeros(length(kRange), 1); % To store average errors

% Loop through each value of k and compute the average reconstruction error across multiple trials
for i = 1:length(kRange)
    k = kRange(i);
    trialErrors = zeros(numTrials, 1);
    
    for t = 1:numTrials
        try
            % Perform NMF for the current number of clusters
            [W, H] = nnmf(data, k);
            
            % Calculate the reconstruction error as a measure of fit
            reconstruction = W * H;
            trialErrors(t) = norm(data - reconstruction, 'fro'); % Frobenius norm
        catch ME
            % Catch any errors during factorization and display a warning
            warning(['NMF failed for k = ', num2str(k), ' on trial ', num2str(t), '. Error: ', ME.message]);
            trialErrors(t) = NaN; % Assign NaN if the factorization fails
        end
    end
    
    % Calculate the average reconstruction error for the current k
    errors(i) = mean(trialErrors, 'omitnan');
end

% Plot the average reconstruction error to help identify the optimal number of clusters
figure;
plot(kRange, errors, '-o');
xlabel('Number of Clusters (k)');
ylabel('Average Reconstruction Error');
title('Average Reconstruction Error for Different Numbers of Clusters');
grid on;

% % Select the optimal number of clusters based on the minimum average error
% [~, optimalIdx] = min(errors); % Choose the value of k with the minimum average error
% optimalK = kRange(optimalIdx);
% disp(['Optimal number of clusters (k) identified: ', num2str(optimalK)]);
% 
% % Perform NMF with the optimal number of clusters
% [W, H] = nnmf(data, optimalK);
% 
% % Display the factorized matrices
% disp('Basis matrix (W):');
% disp(W);
% 
% disp('Loading matrix (H):');
% disp(H);
% 
% % Generate heatmaps and plots as in the original code, now using optimalK
% % Heatmap for the basis matrix W (Clusters of Genes)
% figure;
% heatmap(W, 'Colormap', parula);
% title('Heatmap of Basis Matrix (W): Clusters of Genes');
% xlabel('Latent Factors (Gene Clusters)');
% ylabel('Mice (Samples)');
% colorbar;
% 
% % Heatmap for the loading matrix H (Clusters of Mice)
% figure;
% heatmap(H, 'Colormap', parula);
% title('Heatmap of Loading Matrix (H): Gene Association with Latent Factors');
% xlabel('Latent Factors');
% ylabel('Genes');
% colorbar;
% 
% % Plot the basis matrix W to show treatment association with clusters
% figure;
% bar(W);
% title('Basis Matrix (W): Treatment Association with Latent Factors');
% xlabel('Mice Individual');
% ylabel('Association Strength');
% legend(arrayfun(@(x) ['Cluster ', num2str(x)], 1:optimalK, 'UniformOutput', false));
% 
% % Plot the loading matrix H to show gene association with clusters
% figure;
% bar(H');
% title('Loading Matrix (H): Gene Association with Latent Factors');
% xlabel('Gene');
% ylabel('Loading Coefficient');
% legend(arrayfun(@(x) ['Cluster ', num2str(x)], 1:optimalK, 'UniformOutput', false));
% 
% % Display the top 10 genes with the highest loading coefficients for each cluster
% for cluster = 1:optimalK
%     gene_loadings = H(cluster, :);
%     [~, top_gene_indices] = maxk(gene_loadings, 10);
%     
%     disp(['Top 10 genes for Cluster ', num2str(cluster), ':']);
%     for i = 1:length(top_gene_indices)
%         gene_index = top_gene_indices(i);
%         disp(['Gene ', geneNames{gene_index}, ': Loading Coefficient = ', num2str(gene_loadings(gene_index))]);
%     end
%     
%     % Plot the top 10 genes for the current cluster
%     figure;
%     bar(gene_loadings(top_gene_indices));
%     set(gca, 'XTickLabel', geneNames(top_gene_indices), 'XTickLabelRotation', 45);
%     title(['Top 10 Genes for Cluster ', num2str(cluster)]);
%     xlabel('Gene');
%     ylabel('Loading Coefficient');
% end
