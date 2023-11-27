% Specify the path to  file

function tsne2(varargin)
tic
% filename = 'TSNE_heart 868 FDR 0.05 FC 2.xlsx';

% Initialize the waitbar
hWaitBar = waitbar(0, 'Initializing...');





global geneNames Y highlighted scatterPlot geneIndices isHighlightedMode ;
global clusterIdx;
data=  getappdata(0, 'correlations');
geneNames= getappdata(0,'variable_names');
% Load gene names from the entire first row
% geneNames = readcell(filename, 'Range', '1:1');
%
% % Remove empty cells from geneNames
% geneNames = geneNames(~cellfun('isempty', geneNames));
%
% % Load data, excluding the first row and first column
% data = readmatrix(filename, 'Range', 'B2');
% data = data.^1;

% Run t-SNE

% A higher perplexity value makes the algorithm consider more distant
% points as neighbors, which can help spread out clusters that are too tight.
% Typical values range from 5 to 50, but this depends on the size of your dataset. For larger datasets, a higher perplexity may be needed.

% Update the waitbar after loading and preparing data
waitbar(0.2, hWaitBar, 'Performing t-SNE computation...');

sz = 18;
%Y = tsne(data, 'NumDimensions', 2, 'Perplexity', 40, 'LearnRate', 200, 'NumPCAComponents', 25, sz);

Y = tsne(data, 'NumDimensions', 2, 'Perplexity', 40, 'LearnRate', 200,sz);

% Update the waitbar after completing t-SNE
waitbar(0.6, hWaitBar, 'Plotting results...');
% Plotting the t-SNE results
f =figure;



% Assuming 'f' is your figure handle
set(f, 'Position', [100, 100, 800, 600]); % Resize the figure window
% Set the figure's resize function
set(f, 'ResizeFcn', @resizeFigure);

% Set the position of the scatter plot
set(gca, 'Position', [0.1, 0.1, 0.50, 0.8]);

% % Set the position of the uitable
% set(uitableHandle, 'Position', [560, 100, 200, 300]); % Adjust as needed

scatterPlot = scatter(Y(:,1), Y(:,2));
title('t-SNE visualization');
xlabel('Dimension 1');
ylabel('Dimension 2');



% Create a push button for K-means clustering
btn = uicontrol('Style', 'pushbutton', 'String', 'Cluster',...
    'Position', [500,480,100,35],... % Adjust position and size as needed
    'Callback', {@clusterCallback, data, Y, geneNames}); % Pass data, Y, and geneNames to the callback

% Create a push button for clearing clusters
clearClusterBtn = uicontrol('Style', 'pushbutton', 'String', 'Clear Clusters',...
    'Position', [500, 430, 100, 35],... % Adjust position and size as needed
    'Callback', @clearClustersCallback); % Define the callback function

% Create a push button for selecting a gene list file
selectFileBtn = uicontrol('Style', 'pushbutton', 'String', 'Select Gene List File',...
    'Position', [500, 380, 100, 35],... % Adjust position and size as needed
    'Callback', @selectFileCallback); % Define the callback function

% Create a push button for clearing highlighted genes
clearBtn = uicontrol('Style', 'pushbutton', 'String', 'Clear Highlights',...
    'Position', [500, 330, 100, 35],... % Adjust position and size as needed
    'Callback', @clearHighlightsCallback); % Define the callback function


% Before plotting highlighted genes
% global highlighted;
% global geneNames;
% global Y;
% global highlighted;

% Plotting highlighted genes...

% Create a static text label for the table

% Update and close the waitbar after completing all tasks
waitbar(1, hWaitBar, 'Completed.');
close(hWaitBar);

global uitableTitle
uitableTitle = uicontrol('Style', 'text', 'String', 'Brushed Genes', ...
    'Position', [622, 537, 150, 20], ... % Position above the uitable
    'HorizontalAlignment', 'center');

% Create a uitable for displaying brushed gene names
uitableHandle = uitable('Data', cell(1, 1), ... % Initially empty, with 1 row
    'ColumnName', {'Brushed Genes'}, ...
    'Position', [622,63,150,474]); % Adjust the position and size as needed




% Add data tips
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn', {@myupdatefcn, geneNames, Y});

% Enable brushing
brush on;

% Link brushing to a callback function
hBrush = brush(gcf);
set(hBrush, 'ActionPostCallback', {@brushedCallback, geneNames, Y});

% Modify the set command for the brush to include uitableHandle
set(hBrush, 'ActionPostCallback', {@brushedCallback, geneNames, Y, uitableHandle});


% Assuming you have a variable `isHighlightedMode` that is true when in highlighted mode
    function brushedCallback(~, event, geneNames, Y, uitableHandle, isHighlightedMode)
        %     if isHighlightedMode
        %         % Skip the usual operations if in highlighted mode
        %         return;
        %     end

        try
            % Your existing code to get brushedIndices
            scatterPlot = event.Axes.Children(1);
            brushedIndices = find(scatterPlot.BrushData);

            % Additional code to update uitable
            if ~isempty(brushedIndices) && all(brushedIndices <= length(geneNames))
                brushedGeneNames = geneNames(brushedIndices);
                % Convert brushedGeneNames to a cell array with each gene name in its own row
                brushedGeneNamesCellArray = reshape(brushedGeneNames, [], 1);
                % Update the uitable with brushed gene names
                uitableHandle.Data = brushedGeneNamesCellArray;
            else
                % Clear the uitable if no points are brushed or there's an error
                uitableHandle.Data = cell(10, 1);  % Adjust the size as necessary
            end

        catch ME
            % Display error message and clear the uitable
            disp('An error occurred in the brushedCallback function:');
            disp(ME.message);
            uitableHandle.Data = cell(10, 1);
        end

        % Read the list of genes from the text file
        genesOfInterest = readcell(geneListFile);

        % Convert genesOfInterest to lowercase (or uppercase)
        genesOfInterest = lower(genesOfInterest);

        % Convert geneNames to lowercase (or uppercase) for case-insensitive matching
        geneNamesLower = lower(geneNames);


        % Find the indices of these genes in geneNames
        [~, geneIndices] = ismember(genesOfInterest, geneNamesLower);

        % Highlight these genes on the t-SNE plot
        hold on;
        sz = 20; 
        highlighted = scatter(Y(geneIndices, 1), Y(geneIndices, 2), 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', sz);
        hold off;

        % % Add a legend to the plot
        % legend([scatterPlot, highlighted], {'All Genes', 'Highlighted Genes'}, 'Location', 'best');
        % % Check if the original scatter plot is available and valid
        % if ~isempty(scatterPlot) && isvalid(scatterPlot)
        %     legend([scatterPlot, highlighted], {'All Genes', 'Highlighted Genes'}, 'Location', 'best');
        % else
        %     legend(highlighted, 'Highlighted Genes', 'Location', 'best');
        % end
    end

% Define the custom data tip update function

    function txt = myupdatefcn(~, event_obj, geneNames, Y)


        pos = event_obj.Position;
        % Find the closest point in Y
        distances = sqrt(sum((Y - pos).^2, 2));
        [~, idx] = min(distances);
        geneName = geneNames{idx};

        % Include the cluster number in the data tip
        if ~isempty(clusterIdx) && idx <= length(clusterIdx)
            clusterNumber = clusterIdx(idx);
            clusterText = ['Cluster: ', num2str(clusterNumber)];
        else
            clusterText = 'Cluster: N/A';
        end

        txt = {['X: ', num2str(pos(1))], ['Y: ', num2str(pos(2))], ['Gene: ', geneName], clusterText};
    end


%% Callback function for the button Cluster

    function clusterCallback(src, event, data, Y, geneNames)
        %     global uitableTitle; % Make sure uitableTitle is declared as global
        %      global clusterIdx; % Use the global declaration
        numClusters = str2double(inputdlg('Enter number of clusters:'));
        if ~isempty(numClusters) && numClusters > 0
            % Update the table title with the number of clusters
            if ~isempty(uitableTitle) && isvalid(uitableTitle)
                set(uitableTitle, 'String', ['Clusters Selected: ' num2str(numClusters)]);
            else
                disp('uitableTitle is not available.');
            end
            % Initialize the waitbar
            hWaitBar = waitbar(0, 'Performing K-means clustering...');
            % Update the waitbar
            waitbar(0.5, hWaitBar, 'Updating plot...');
            % Perform K-means clustering
            [clusterIdx, ~] = kmeans(data, numClusters);

            % Update the global clusterIdx variable after performing k-means clustering
            clusterIdx = kmeans(data, numClusters);

            % Update the waitbar
            waitbar(1, hWaitBar, 'Updating plot...');
            close (hWaitBar);
            % Update the scatter plot
            cla; % Clear the current axes
            gscatter(Y(:,1), Y(:,2), clusterIdx); % Use gscatter for coloring based on clusters
            title('t-SNE visualization with K-means Clustering');
            xlabel('Dimension 1');
            ylabel('Dimension 2');



            % Create a new figure for the clustering results table
            clusterResultsFig = uifigure;
            set(clusterResultsFig, 'Position', [900, 100, 320, 500], 'Name', 'IVCCA (Berezin Lab)', 'Icon','Corr_icon.png'); % Adjust as needed




            % Create data for the table
            tableData = [geneNames(:), num2cell(clusterIdx)]; % Pair gene names with cluster index

            % Create a static text label for the kmeans_table title
            kmeansTableTitle = uilabel('Parent', clusterResultsFig, ...
                'Text', ['Clusters Selected: ' num2str(numClusters)], ...
                'Position', [10, 470, 300, 30], ... % Adjust size and position as needed
                'HorizontalAlignment', 'center');

            % Create the table
            kmeans_table =uitable('Parent', clusterResultsFig, 'Data', tableData, ...
                'ColumnName', {'Gene Name', 'Cluster'}, ...
                'Position', [10, 10, 300, 460]); % Adjust size and position as needed
            kmeans_table.ColumnSortable(2) = true;
            kmeans_table.ColumnSortable(1) = true;

        end
    end

%% Callback function to clear clusters from the t-SNE plot
    function clearClustersCallback(src, event)
        %     global Y; % Assuming Y (t-SNE results) is available globally
        %     global scatterPlot; % Handle for the original scatter plot
        %     global highlighted; % Handle for highlighted points

        % Check if the original scatter plot handle is valid
        if ~isempty(scatterPlot) && isvalid(scatterPlot)
            delete(scatterPlot); % Delete the existing scatter plot
        end

        % Redraw the original scatter plot
        scatterPlot = scatter(Y(:,1), Y(:,2));
        title('t-SNE visualization');
        xlabel('Dimension 1');
        ylabel('Dimension 2');

        % Redraw highlighted points if they exist
        if ~isempty(highlighted) && isvalid(highlighted)
            % Assuming geneIndices is globally available and valid
            %         global geneIndices;
            hold on;
            highlighted = scatter(Y(geneIndices, 1), Y(geneIndices, 2), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
            hold off;
        end
    end

%% Callback function for selecting a gene list file
    function selectFileCallback(src, event)
        %     global geneNames Y highlighted scatterPlot;

        %     % When exiting highlighted mode
        % isHighlightedMode = true;

        % Open file selection dialog
        [file, path] = uigetfile('*.txt', 'Select a gene list file');
        if file == 0
            return; % User canceled file selection
        end

        % Full path to the selected file
        fullFilePath = fullfile(path, file);

        % Read the list of genes from the selected file
        genesOfInterest = readcell(fullFilePath);

        % Convert to proper format if necessary (ensure cell array of strings)
        if ischar(genesOfInterest)
            genesOfInterest = cellstr(genesOfInterest);
        end

        % Convert genesOfInterest and geneNames to lowercase for case-insensitive matching
        genesOfInterestLower = lower(genesOfInterest);
        geneNamesLower = lower(geneNames);

        % Find the indices of these genes in geneNames
        [isInList, geneIndices] = ismember(genesOfInterestLower, geneNamesLower);

        % Debugging: Display which genes were found and their indices
        foundGenes = genesOfInterest(isInList);
        disp('Genes found in the list:');
        disp(foundGenes);

        % Filter out indices that are not found (i.e., zero)
        validIndices = geneIndices(isInList);

        % Debugging: Check for any unexpected zero indices
        if any(validIndices == 0)
            disp('Warning: Some genes not found in geneNames.');
        end

        % Highlight these genes on the t-SNE plot
        if ~isempty(highlighted) && ishandle(highlighted)
            delete(highlighted);  % Clear previous highlights
        end
        hold on;
        highlighted = scatter(Y(validIndices, 1), Y(validIndices, 2), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');

        % Check if the original scatter plot is available and valid
        if ~isempty(scatterPlot) && isvalid(scatterPlot)
            legend([scatterPlot, highlighted], {'All Genes', 'Highlighted Genes'}, 'Location', 'best');
        else
            legend(highlighted, 'Highlighted Genes', 'Location', 'best');
        end

        hold off;
        % % When exiting highlighted mode
        % isHighlightedMode = false;
    end


%% Callback function to clear highlighted points
    function clearHighlightsCallback(src, event)
        % Assuming 'highlighted' is the handle to your highlighted scatter points
        %     global highlighted;
        if ~isempty(highlighted) && isvalid(highlighted)
            delete(highlighted); % Delete the highlighted points
            highlighted = []; % Clear the handle
        end
    end

% Define the resize function
    function resizeFigure(src, ~)
        figPos = get(src, 'Position');

        % Adjust button positions based on figure size
        set(btn, 'Position', [figPos(3)-300, figPos(4)-120, 100, 35]);
        set(clearClusterBtn, 'Position', [figPos(3)-300, figPos(4)-160, 100, 35]);
        set(selectFileBtn, 'Position', [figPos(3)-300, figPos(4)-200, 100, 35]);
        set(clearBtn, 'Position', [figPos(3)-300, figPos(4)-240, 100, 35]);

        % Adjust uitable position
        set(uitableHandle, 'Position', [figPos(3)-178, 63, 150, figPos(4)-140]);

        % Adjust uitable title position
        set(uitableTitle, 'Position', [figPos(3)-178, figPos(4)-123, 150, 20]);

        % Adjust the scatter plot position
        set(gca, 'Position', [0.1, 0.1, 0.50, 0.8]);
    end
toc
end

