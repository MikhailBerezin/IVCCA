%% Dynamic_tree_cut function (not activated)
function dynamic_tree_cut_callback(~, ~, f)
    % Get the correlations from the app data
    correlations = getappdata(0, 'correlations');
    correlations = abs(correlations);
    variable_names = getappdata(0, 'variable_names');
    
%     % Ask the user to specify cutoff_cl
    prompt = {'Enter cutoff value (default is 0.15):'};
    dlgtitle = 'Cutoff Input';
    dims = [1 35];
    definput = {'0.15'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    % If the user presses Cancel, the answer is empty. 
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

% Calculate the inconsistency coefficient for each link
inconsistency = inconsistent(Z);

% Determine a threshold for cutting the dendrogram, possibly based on the distribution of inconsistency values
% cutoff_cl = prctile(inconsistency(:, 4), 40); % for example, setting cutoff at 75th percentile of the inconsistency scores


    T = cluster(Z, 'Cutoff', cutoff_cl * max(Z(:,3)), 'Criterion', 'distance'); % Larger cutoff value corresponds to fewer clusters

    % Display the number of members in each cluster in the Command Window
    unique_clusters = unique(T);
    disp('Cluster Results:');
    for i = 1:length(unique_clusters)
        cluster_members = variable_names(T == unique_clusters(i));
        disp(['Cluster ' num2str(i) ' (Size: ' num2str(length(cluster_members)) '):']);
        disp(strjoin(cluster_members, ', '));
    end

    % Save the cluster assignments to the app data for further processing
    setappdata(f, 'dynamic_tree_clusters', T);
    
    % Organize the correlation matrix according to the clusters
    [~, order] = sort(T);
    ordered_correlations = correlations(order, order);
    
    % Create a heatmap using the ordered correlation matrix
    figure ('Name', 'IVCCA: Dynamic Tree Cutting', 'NumberTitle', 'off');
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