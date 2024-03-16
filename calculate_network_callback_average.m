function calculate_network_callback_average(~, ~, f)
f.WindowStyle = 'normal';


% Retrieve correlation data and variable names (gene names)
cor_data = abs(getappdata(0, 'correlations'));
geneNames = getappdata(0, 'variable_names');

% Ask the user if they want to filter the gene set
choice = uiconfirm(f, 'Would you like to filter for the gene set (optional)?', 'Open Gene List', ...
    'Options', {'Yes', 'No'}, 'DefaultOption', 1, 'CancelOption', 2);

if strcmp(choice, 'Yes')
    % User chooses to filter for the gene set
    [file, path] = uigetfile('*.txt', 'Select the file with the gene list');
    if isequal(file, 0)
        disp('User selected Cancel');
        return;
    else
        disp(['User selected ', fullfile(path, file)]);
        % Read the list of genes from the file
        fileID = fopen(fullfile(path, file), 'r');
        filterGeneNames = textscan(fileID, '%s');
        filterGeneNames = filterGeneNames{1}; % Convert cell array to a regular array of strings
        fclose(fileID);

        % Filter the correlation data and gene names
        [isValidGene, loc] = ismember(geneNames, filterGeneNames);
        cor_data = cor_data(isValidGene, isValidGene);
        geneNames = geneNames(isValidGene);
    end
else
    % If the user chooses 'No', or closes the dialog, proceed without filtering
    disp('Proceeding without gene set filtering.');
end

% Define the prompt, title, and default value for the input dialog
prompt = {'Enter the correlation threshold:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'0.75'}; % default value set to 0.75

% Create the input dialog box
answer = inputdlg(prompt, dlgtitle, dims, definput);

% Validate and parse the input
% Instead of a single threshold, loop from the user-defined threshold to 0.95, incrementing by 0.05
correlationThreshold = 0.75; % Default threshold
if ~isempty(answer)
    tempValue = str2double(answer{1});
    if ~isnan(tempValue) && tempValue >= 0 && tempValue <= 1
        correlationThreshold = tempValue;
    else
        % Display a message if the input is invalid
        msgbox('Invalid input. Using default value of 0.75.', 'Error', 'error');
    end
end

% Initialize variables to calculate average degrees and edge weights
totalDegrees = zeros(length(geneNames), 1);
totalEdgeWeights = zeros(size(cor_data));  % Same size as correlation data to hold edge weights
countThresholds = 0;


for threshold = correlationThreshold:0.01:0.99
    % Filter the correlation matrix for the current threshold
    filteredCorData = cor_data;
    filteredCorData(abs(filteredCorData) < threshold) = 0;


     % Create a graph object from the filtered correlation matrix
    G = graph(filteredCorData, geneNames, 'OmitSelfLoops');
    G = rmedge(G, find(G.Edges.Weight < threshold)); % Remove edges below the threshold

    % Accumulate the edge weights
   for ei = 1:numedges(G)
    edgeInfo = G.Edges(ei, :);  % Get edge information
    src = find(strcmp(geneNames, edgeInfo.EndNodes{1}));  % Convert node name to index
    dst = find(strcmp(geneNames, edgeInfo.EndNodes{2}));  % Convert node name to index
    weight = edgeInfo.Weight;

      if isempty(src) || isempty(dst)
        continue;  % Skip if any index is not found
      end

    totalEdgeWeights(src, dst) = totalEdgeWeights(src, dst) + weight;
    totalEdgeWeights(dst, src) = totalEdgeWeights(dst, src) + weight;  % For undirected graph
   end

    % Calculate the degree for each node
    nodeDegree = degree(G);

    % Accumulate the degree counts
    totalDegrees = totalDegrees + nodeDegree;
    countThresholds = countThresholds + 1;


end


% Calculate the average degree and average edge weights
avgDegree = totalDegrees / countThresholds;
avgEdgeWeights = totalEdgeWeights / countThresholds;

% Create a graph from the final filtered correlation matrix
% Note: You might want to use the average or another representation of the correlation matrix here
G = graph(filteredCorData, geneNames, 'OmitSelfLoops');
G = rmedge(G, find(G.Edges.Weight < correlationThreshold)); % remove edges below the final threshold

% Set edge weights based on correlation values (if necessary)
G.Edges.Weight = abs(G.Edges.Weight); % Using absolute values of correlation
% Assign 'avgDegree' as a node property
G.Nodes.AvgDegree = avgDegree;

% % Number of nodes
numNodes = numnodes(G);

% Generate coordinates for plotting
[x, y] = circlePoints(numNodes);

% Plot the network
figure; % Open a new figure


% Calculate line widths based on average edge weights
lineWidths = zeros(numedges(G), 1);  % Initialize an array for line widths

for ei = 1:numedges(G)
    srcNode = find(strcmp(geneNames, G.Edges.EndNodes{ei, 1}));  % Convert node name to index
    destNode = find(strcmp(geneNames, G.Edges.EndNodes{ei, 2}));  % Convert node name to index

    if isempty(srcNode) || isempty(destNode)
        continue;  % Skip if any index is not found
    end

    minLineWidth = 0.6; % Minimum line width
    maxLineWidth = 4; % Maximum line width
    lineWidths(ei) = minLineWidth + (maxLineWidth - minLineWidth) * avgEdgeWeights(srcNode, destNode);

% lineWidths(ei) = minLineWidth + ((G.Edges.Weight / maxWeight) * 0.32*(maxLineWidth - minLineWidth)).^12;
end


% Plot the network with specified edge line widths
p = plot(G, 'XData', x, 'YData', y, 'EdgeColor', [91, 207, 244] / 255, 'NodeFontSize', 14, 'LineWidth', mean(lineWidths));

resultsTable = table(geneNames', avgDegree, 'VariableNames', {'GeneName', 'AvgDegree'});

% Create a UI figure to display the table
figureTitle = sprintf('Degree of Connection (Threshold: %.2f)', correlationThreshold);
f = uifigure('Name', figureTitle, 'Position', [100 100 300 250]);
t = uitable('Parent', f, 'Data', resultsTable, 'Position', [20 20 260 200]);
t.ColumnSortable(1) = true;
t.ColumnSortable(2) = true;

end


function [x, y] = circlePoints(n)
% Generate n points distributed on the circumference of a circle
theta = linspace(0, 2*pi, n);  % n points evenly spaced around the circle

% The radius of the circle is assumed to be 1 for simplicity
% If you want a different radius, multiply x and y by the radius
x = cos(theta);  % x coordinate
y = sin(theta);  % y coordinate

end
