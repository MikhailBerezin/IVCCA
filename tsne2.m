function tsne2(varargin)
tic

% Initialize the waitbar
hWaitBar = waitbar(0, 'Initializing...');

global geneNames Y highlighted scatterPlot geneIndices isHighlightedMode ;
global clusterIdx;
data=  getappdata(0, 'correlations');
geneNames= getappdata(0,'variable_names');


% Run t-SNE

% A higher perplexity value makes the algorithm consider more distant
% points as neighbors, which can help spread out clusters that are too tight.
% Typical values range from 5 to 50, but this depends on the size of your dataset. For larger datasets, a higher perplexity may be needed.

% Update the waitbar after loading and preparing data
waitbar(0.2, hWaitBar, 'Performing t-SNE computation...');

% Fill NaN values in data with 0 (or any other suitable number)
dataFilled = fillmissing(data, 'constant', 0);

%Y = tsne(data, 'NumDimensions', 2, 'Perplexity', 40, 'LearnRate', 200, 'NumPCAComponents', 25, sz);
% 3D tsne
Y = tsne(dataFilled, 'NumDimensions', 3, 'Perplexity', 40, 'LearnRate', 200, 'NumPCAComponents', 25);

% Update the waitbar after completing t-SNE
waitbar(0.6, hWaitBar, 'Plotting results...');

% Plotting the t-SNE results
% Get the size of the screen
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Define the size of the figure
figWidth = 800;  % adjust width
figHeight = 560; % adjust height

% Calculate the position to center the figure
posX = (screenWidth - figWidth) / 2;
posY = (screenHeight - figHeight) / 2;
f =figure ( 'Name', 'IVCCA: t-SNE visualization', 'NumberTitle', 'off', 'Position', [posX posY figWidth figHeight]);

% Set the figure's resize function
set(f, 'ResizeFcn', @resizeFigure);

% % Set the position of the 2D scatter plot
% set(gca, 'Position', [0.1, 0.1, 0.50, 0.85]);
% sz = 25;
% scatterPlot = scatter(Y(:,1), Y(:,2), sz);
% title('t-SNE visualization');
% xlabel('Dimension 1');
% ylabel('Dimension 2');


% Use scatter3 for 3D scatter plot
scatterPlot = scatter3(Y(:,1), Y(:,2), Y(:,3), 25);
title('3D t-SNE visualization');
xlabel('Dimension 1');
ylabel('Dimension 2');
zlabel('Dimension 3'); % New label for the third dimension

% Create a push button for K-means clustering
btn = uicontrol('Style', 'pushbutton', 'String', 'Cluster',...
    'Position', [500,480,100,35],... % Adjust position and size as needed
    'Callback', {@clusterCallback, data, Y, geneNames}); % Pass data, Y, and geneNames to the callback

% Create a push button for clearing clusters
clearClusterBtn = uicontrol('Style', 'pushbutton', 'String', 'Clear Clusters',...
    'Position', [500, 430, 100, 35],... % Adjust position and size as needed
    'Callback', @clearClustersCallback); % Define the callback function

% Create a push button for selecting a gene list file
selectFileBtn = uicontrol('Style', 'pushbutton', 'String', 'Select Pathway',...
    'Position', [500, 380, 100, 35],... % Adjust position and size as needed
    'Callback', @selectFileCallback); 

% Create a push button for clearing highlighted genes
clearBtn = uicontrol('Style', 'pushbutton', 'String', 'Clear Highlights',...
    'Position', [500, 330, 100, 35],... % Adjust position and size as needed
    'Callback', @clearHighlightsCallback); 

% Create an input field for gene name
searchField = uicontrol('Style', 'edit', ...
    'Position', [500, 280, 100, 35], ... % Adjust position and size as needed
    'String', 'Enter Gene Name');

% Create a search button
searchBtn = uicontrol('Style', 'pushbutton', 'String', 'Search Gene',...
    'Position', [500, 230, 100, 35],... % Adjust position and size as needed
    'Callback', @searchGeneCallback); % Define the callback function



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
        sz = 25; 
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

% Custom data tip update function

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
        tic
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
%             [clusterIdx, ~] = kmeans(dataFilled, numClusters,"cityblock");

            % Update the global clusterIdx variable after performing k-means clustering
            clusterIdx = kmeans(dataFilled, numClusters, "Distance","cityblock");

            % Update the waitbar
            waitbar(1, hWaitBar, 'Updating plot...');
            close (hWaitBar);
         
%             % Update the scatter plot
%             cla; % Clear the current axes
%             gscatter(Y(:,1), Y(:,2), clusterIdx); % Use gscatter for coloring based on clusters
%             title('t-SNE visualization with K-means Clustering');
%             xlabel('Dimension 1');
%             ylabel('Dimension 2');

        % Update the scatter plot for 3D
        cla; % Clear the current axes
        scatter3(Y(:,1), Y(:,2), Y(:,3), 10, clusterIdx, 'filled'); % Use scatter3 for 3D plot
        title('3D t-SNE visualization with K-means Clustering');
        xlabel('Dimension 1');
        ylabel('Dimension 2');
        zlabel('Dimension 3'); % Label for the third dimension


            % Create a new figure for the clustering results table
            clusterResultsFig = uifigure;
            set(clusterResultsFig, 'Position', [900, 100, 320, 500], 'Name', 'IVCCA (Berezin Lab)', 'Icon','Corr_icon.png'); % Adjust as needed

            % Create data for the table
            tableData = [geneNames(:), num2cell(clusterIdx)]; % Pair gene names with cluster index

            % Create a static text label for the kmeans_table title
            kmeansTableTitle = uilabel('Parent', clusterResultsFig, ...
                'Text', ['Clusters Selected: ' num2str(numClusters)], ...
                'Position', [10, 470, 300, 30], ... 
                'HorizontalAlignment', 'center');

            % Create the table
            kmeans_table =uitable('Parent', clusterResultsFig, 'Data', tableData, ...
                'ColumnName', {'Gene Name', 'Cluster'}, ...
                'Position', [10, 10, 300, 460]); 
            kmeans_table.ColumnSortable(2) = true;
            kmeans_table.ColumnSortable(1) = true;

        end
        toc
    end

%% Callback function to clear clusters from the t-SNE plot
    function clearClustersCallback(src, event)
    

% Check if the original scatter plot handle is valid
    if ~isempty(scatterPlot) && isvalid(scatterPlot)
        % Preserve the brush data
        brushData = scatterPlot.BrushData;

        % Delete the existing scatter plot
        delete(scatterPlot);
    else
        % Initialize brushData as empty if scatterPlot is not valid
        brushData = [];
    end

    % Clear the global clusterIdx variable
    clusterIdx = [];

%     % Redraw the original 2D scatter plot
%     scatterPlot = scatter(Y(:,1), Y(:,2), sz);
%     title('t-SNE visualization');
%     xlabel('Dimension 1');
%     ylabel('Dimension 2');


    % Redraw the scatter plot for 3D
       
        scatterPlot = scatter3(Y(:,1), Y(:,2), Y(:,3), 25); % Use scatter3 for 3D plot
        title('3D t-SNE visualization ');
        xlabel('Dimension 1');
        ylabel('Dimension 2');
        zlabel('Dimension 3'); % Label for the third dimension
    

    % Restore the brush data
    scatterPlot.BrushData = brushData;

    % Update the brush callback to reference the new scatterPlot
    hBrush = brush(gcf);
    set(hBrush, 'ActionPostCallback', {@brushedCallback, geneNames, Y, uitableHandle});

    % Redraw highlighted points if they exist
    if ~isempty(highlighted) && isvalid(highlighted)
        hold on;
        %for 2D
%         highlighted = scatter(Y(geneIndices, 1), Y(geneIndices, 2), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        %for3D
        highlighted = scatter3(Y(geneIndices, 1), Y(geneIndices, 2), Y(geneIndices, 3), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        hold off;
    end
end

%% Callback function for selecting a gene list file
function selectFileCallback(src, event)
    % Use a persistent variable to remember the last directory
    persistent lastDir

    % Check if lastDir is empty or not a valid path, and set default if necessary
    if isempty(lastDir) || ~isfolder(lastDir)
        lastDir = pwd; % Set to current working directory as default
    end

    % Open file selection dialog, starting from the last accessed directory
    [file, path] = uigetfile({'*.txt', 'Select a gene list file'}, 'Select a gene list file', lastDir);
    if file == 0
        return; % User canceled file selection
    end

    % Update lastDir with the new path
    lastDir = path;

    % Full path to the selected file
    fullFilePath = fullfile(path, file);

    % Extract just the name of the file, without the extension
    [filePath, fileName, fileExt] = fileparts(fullFilePath);

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
    % for 3D
    highlighted = scatter3(Y(validIndices, 1), Y(validIndices, 2), Y(validIndices, 3), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');

    % Check if the original scatter plot is available and valid
    if ~isempty(scatterPlot) && isvalid(scatterPlot)
        legend([scatterPlot, highlighted], {'All Genes', fileName}, 'Location', 'best');
    else
        legend(highlighted, fileName, 'Location', 'best');
    end

    hold off;
end




%% Callback function to clear highlighted points
    function clearHighlightsCallback(src, event)
       
        if ~isempty(highlighted) && isvalid(highlighted)
            delete(highlighted); % Delete the highlighted points
            highlighted = []; % Clear the handle
        end
    end

% Resize function
    function resizeFigure(src, ~)
        figPos = get(src, 'Position');

        % Adjust button positions based on figure size
        set(btn, 'Position', [figPos(3)-300, figPos(4)-120, 100, 35]);
        set(clearClusterBtn, 'Position', [figPos(3)-300, figPos(4)-160, 100, 35]);
        set(selectFileBtn, 'Position', [figPos(3)-300, figPos(4)-200, 100, 35]);
        set(clearBtn, 'Position', [figPos(3)-300, figPos(4)-240, 100, 35]);
        set(searchField, 'Position', [figPos(3)-300, figPos(4)-280, 100, 35]);
        set(searchBtn, 'Position', [figPos(3)-300, figPos(4)-320, 100, 35]);

        % Adjust uitable position
        set(uitableHandle, 'Position', [figPos(3)-178, 63, 150, figPos(4)-140]);

        % Adjust uitable title position
        set(uitableTitle, 'Position', [figPos(3)-178, figPos(4)-123, 150, 20]);

        % Adjust the scatter plot position
        set(gca, 'Position', [0.1, 0.1, 0.50, 0.8]);
    end
toc
function searchGeneCallback(src, event)
%     global Y geneNames highlighted;

  % Get the gene name from the input field
    geneToFind = get(searchField, 'String');

    % Find the index of the gene
    geneIndex = find(strcmpi(geneNames, geneToFind));

    if isempty(geneIndex)
        disp(['Gene ' geneToFind ' not found.']);
        return;
    end

    % Highlight the found gene on the scatter plot
    if ~isempty(highlighted) && isvalid(highlighted)
        delete(highlighted); % Clear any previous highlights
    end
    hold on;
  %  for 2D
%     highlighted = scatter(Y(geneIndex, 1), Y(geneIndex, 2), 25, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
 %  for 3D
    highlighted = scatter3(Y(geneIndex, 1), Y(geneIndex, 2), Y(geneIndex, 3), 25, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
     

    % Update the legend to show the name of the gene
    if ~isempty(scatterPlot) && isvalid(scatterPlot)
        legend([scatterPlot, highlighted], {'All Genes', geneToFind}, 'Location', 'best');
    else
        legend(highlighted, geneToFind, 'Location', 'best');
    end
    
    hold off;
end

end

