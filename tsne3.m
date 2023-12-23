function tsne3(varargin)
tic

% Initialize the waitbar
hWaitBar = waitbar(0, 'Initializing...');

global geneNames Y highlightedGenes scatterPlot geneIndices isHighlightedMode ;
global clusterIdx;


highlightedGenes = struct('indices', {}, 'colors', {}, 'fileName', {});



data=  getappdata(0, 'correlations');
data = abs(data);
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
% Adjust the scatter plot position
        set(gca, 'Position', [0.1, 0.1, 0.50, 0.8]);
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
selectFileBtn = uicontrol('Style', 'pushbutton', 'String', 'Select Pathway(s)',...
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

% Create and API to String button

stringBtn = uicontrol('Style', 'pushbutton', 'String', 'Connect to STRING',...
    'Position', [500, 180, 100, 35],... % Adjust position and size as needed
    'Callback', @api_to_string_2); % Define the callback function

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

% Enable 3D rotating
rotate3d on;

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
        setappdata(0,'genes',brushedGeneNames)
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
        highlightedGenes = scatter(Y(geneIndices, 1), Y(geneIndices, 2), 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', sz);
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
        scatter3(Y(:,1), Y(:,2), Y(:,3), 10, clusterIdx, 'filled','MarkerEdgeColor', 'k'); % Use scatter3 for 3D plot
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
    if ~isempty(highlightedGenes) && isvalid(highlightedGenes)
        hold on;
        %for 2D
%         highlighted = scatter(Y(geneIndices, 1), Y(geneIndices, 2), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        %for3D
        highlightedGenes = scatter3(Y(geneIndices, 1), Y(geneIndices, 2), Y(geneIndices, 3), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        hold off;
    end
end

%% Callback function for selecting a gene list file
% Global variable declaration at the beginning of tsne2 function
global highlightedGenes;
highlightedGenes = struct('indices', {}, 'colors', {}, 'fileName', {});

function selectFileCallback(src, event)


   persistent lastPath; % Declare a persistent variable to store the last used path
    setappdata(0,'cluster',0)
    if isempty(lastPath)
        lastPath = pwd; % If lastPath is empty, set it to the current directory
    end

    % Open file selection dialog and read genes of interest
    [file, path] = uigetfile({'*.txt', 'Select a gene list file'}, 'Select a gene list file', lastPath, 'MultiSelect', 'on');
    if file == 0
        return; % User canceled file selection
    else
        lastPath = path; % Update lastPath with the new directory
    end
if ischar(file)
    
    file_path = fullfile(path, file);
    genesOfInterest = textread(file_path, '%s');

%     genesOfInterest = readcell(fullfile(path, file));

    % Convert genesOfInterest and geneNames to lowercase for case-insensitive matching
    genesOfInterestLower = lower(genesOfInterest);
    geneNamesLower = lower(geneNames);

    % Find the indices of these genes in geneNames
    [isInList, geneIndices] = ismember(genesOfInterestLower, geneNamesLower);
    validIndices = geneIndices(isInList);

    % Append new highlighted genes to the highlightedGenes structure
    newColor = rand(1,3); % Generate a new color
%     [~, fileName, ~] = fileparts(file); % Extract the file name without extension

    fileName=file;

    newStruct = struct('indices', validIndices, 'colors', newColor, 'fileName', fileName);
    highlightedGenes = [highlightedGenes, newStruct];
    
    % Call the function to calculate and display nearest neighbor distances
    calculateAndDisplayNearestNeighbor(Y, validIndices);

    % Update the scatter plot
    updateScatterPlot();
   
else
    for i = 1:length(file)
     setappdata(0,'cluster',1)  
     file_path = fullfile(path, file{i});
       
    genesOfInterest = textread(file_path, '%s');

%     genesOfInterest = readcell(fullfile(path, file));

    % Convert genesOfInterest and geneNames to lowercase for case-insensitive matching
    genesOfInterestLower = lower(genesOfInterest);
    geneNamesLower = lower(geneNames);

    % Find the indices of these genes in geneNames
    [isInList, geneIndices] = ismember(genesOfInterestLower, geneNamesLower);
    validIndices = geneIndices(isInList);

    % Append new highlighted genes to the highlightedGenes structure
    newColor = rand(1,3); % Generate a new color
%     [~, fileName, ~] = fileparts(file); % Extract the file name without extension

    fileName=  file{i};

    newStruct = struct('indices', validIndices, 'colors', newColor, 'fileName', fileName);
    highlightedGenes = [highlightedGenes, newStruct];
    
    % Call the function to calculate and display nearest neighbor distances
    calculateAndDisplayNearestNeighbor(Y, validIndices);

    % Update the scatter plot
    updateScatterPlot();
    end
end
end

function distributionSummary = calculateAndDisplayNearestNeighbor(Y, highlightedIndices)
    if isempty(highlightedIndices)
        msgbox('No genes in the set.');
        return;
    end

    % Calculate nearest neighbor distance for each point in highlightedIndices
    distances = zeros(size(highlightedIndices));
    for i = 1:length(highlightedIndices)
        point = Y(highlightedIndices(i), :);
        otherPoints = Y;
        otherPoints(highlightedIndices(i), :) = []; % Exclude the point itself
        distToOtherPoints = sqrt(sum((otherPoints - point).^2, 2));
        distances(i) = min(distToOtherPoints);
    end

    % Density estimation for each dimension separately
    densityB = zeros(length(highlightedIndices), 1);
    for dim = 1:size(Y, 2)
        [density, xi] = ksdensity(Y(:,dim), 'Kernel', 'normal');
        densityB = densityB + interp1(xi, density, Y(highlightedIndices, dim), 'linear', 'extrap');
    end

 % Calculate summary statistics
numPoints = length(highlightedIndices); % Number of identified points
meanDistance = mean(distances);
medianDistance = median(distances);
stdDistance = std(distances);
meanDensity = mean(densityB);
medianDensity = median(densityB);


% Create a table with two columns and six rows
    metricNames = {'Number of Points','Mean Distance', 'Median Distance', 'Standard Deviation', 'Mean Density', 'Median Density'};
    metricValues = [numPoints,meanDistance, medianDistance, stdDistance, meanDensity, medianDensity]; % Keep numPoints as numeric
    metricValues = num2cell(metricValues); % Convert numeric array to cell array
    distributionSummary = table(metricNames', metricValues', 'VariableNames', {'Metric', 'Value'}); % Note the transposition of metricValues

% Create a uifigure
f = uifigure('Name', 'Distribution Summary', 'Position', [100 100 300 250]); % Adjust height for additional row

% Display the calculated summary in a uitable within the uifigure
disp('Summary of distribution for highlighted genes:');
t = uitable(f, 'Data', distributionSummary, 'Position', [20 20 260 210]); % Adjust height for additional row
end



function updateScatterPlot()
%     global Y highlightedGenes scatterPlot;

    % Clear existing scatter plot and redraw
%     if ~isempty(scatterPlot) && isvalid(scatterPlot)
%         delete(scatterPlot);
%     end
    pl= getappdata(0,'cluster');
    if pl==0
        delete(scatterPlot)
    end
    % Set the default color for non-highlighted points to grey
    scatterPlot = scatter3(Y(:,1), Y(:,2), Y(:,3), 25, [0.7, 0.7, 0.7]); % Grey color
    title('3D t-SNE visualization with K-means Clustering');
    xlabel('Dimension 1');
    ylabel('Dimension 2');
    zlabel('Dimension 3'); % Label for the third dimension

    hold on;
    legendEntries = {'All Genes (Grey)'}; % Updated legend entry
    for i = 1:length(highlightedGenes)
        hp = scatter3(Y(highlightedGenes(i).indices, 1), Y(highlightedGenes(i).indices, 2), Y(highlightedGenes(i).indices, 3), 50, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', highlightedGenes(i).colors);
        fileNameForLegend = strrep(highlightedGenes(i).fileName, '_', '\_'); % Replace underscore with escaped underscore
%         legendEntries{end+1} = highlightedGenes(i).fileName; % Add file name to legend entries
         legendEntries{end+1} = fileNameForLegend;
    end
    hold off;

    % Update the legend
    legend(legendEntries, 'Location', 'best');
end




%% Callback function to clear highlighted points
   function clearHighlightsCallback(src, event)
  
%     global highlightedGenes scatterPlot

    % Clear the highlighted genes data
    highlightedGenes = [];

    % Update the scatter plot to reflect the changes
    updateScatterPlot();

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
        set(stringBtn, 'Position', [figPos(3)-300, figPos(4)-370, 100, 35]);

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
        msgbox(['Gene ' geneToFind ' not found.']);
        return;
    end

    % Highlight the found gene on the scatter plot
    if ~isempty(highlightedGenes) && isvalid(highlightedGenes)
        delete(highlightedGenes); % Clear any previous highlights
    end
    hold on;
  %  for 2D
%     highlighted = scatter(Y(geneIndex, 1), Y(geneIndex, 2), 25, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
 %  for 3D
    highlightedGenes = scatter3(Y(geneIndex, 1), Y(geneIndex, 2), Y(geneIndex, 3), 25, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
     

    % Update the legend to show the name of the gene
    if ~isempty(scatterPlot) && isvalid(scatterPlot)
        legend([scatterPlot, highlightedGenes], {'All Genes', geneToFind}, 'Location', 'best');
    else
        legend(highlightedGenes, geneToFind, 'Location', 'best');
    end
    
    hold off;
end

end

