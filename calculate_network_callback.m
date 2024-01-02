function calculate_network_callback(~, ~, f)
    f.WindowStyle = 'normal';

    % Retrieve correlation data and variable names (gene names)
    cor_data = abs(getappdata(0, 'correlations'));
    geneNames = getappdata(0, 'variable_names');

    % Define the prompt, title, and default value for the input dialog
    prompt = {'Enter the correlation threshold:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'0.75'}; % default value set to 0.75

    % Create the input dialog box
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Validate and parse the input
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

    % Filter the correlation matrix
    filteredCorData = cor_data;
    filteredCorData(abs(filteredCorData) < correlationThreshold) = 0;

    % Create a graph object from the filtered correlation matrix
    G = graph(filteredCorData, geneNames, 'OmitSelfLoops');

    % Remove edges with weight below the threshold
    G = rmedge(G, find(G.Edges.Weight < correlationThreshold));

    % Calculate the degree for each node
    nodeDegree = degree(G);

    % Create a table with gene names and their degrees
    resultsTable = table(geneNames', nodeDegree, 'VariableNames', {'GeneName', 'Degree'});



% Set edge weights based on correlation values
G.Edges.Weight = abs(G.Edges.Weight); % Using absolute values of correlation

% Number of nodes
numNodes = numnodes(G);


% Plot the network in 2D with nodes on a circle
figure; % Open a new figure
[x, y] = circlePoints(numNodes);
p = plot(G, 'XData', x, 'YData', y, 'EdgeColor', 'b', 'NodeFontSize',14);
% Remove box around the plot
box off;

% Remove ticks
% set(gca, 'XTick', [], 'YTick', []);

%  to remove the axis lines entirely:
 axis off;




%% ------------3D-------
% % Plot the network in 3D with nodes on a sphere
% figure; % Open a new figure
% p = plot(G, 'XData', x, 'YData', y, 'ZData', z, 'EdgeColor', 'b');
% [x, y] = spherePoints(numNodes);
% 
% % Plot the network in 3D with nodes on a sphere
% figure; % Open a new figure
% p = plot(G, 'XData', x, 'YData', y, 'ZData', z, 'EdgeColor', 'b');
% 
% % Generate spherical coordinates for each node
% [x, y, z] = spherePoints(numNodes);

% Plot the network in 3D with nodes on a sphere
% figure; % Open a new figure
% p = plot(G, 'XData', x, 'YData', y, 'ZData', z, 'EdgeColor', 'b');
%% --------------

% Adjust line thickness based on correlation value
maxWeight = max(G.Edges.Weight); % Find maximum edge weight
minLineWidth = 0.5; % Minimum line width
maxLineWidth = 4; % Maximum line width
p.LineWidth = minLineWidth + ((G.Edges.Weight / maxWeight) * 0.32*(maxLineWidth - minLineWidth)).^12;

% Adjust node size based on degree
p.MarkerSize = 5 + (1.3 * (nodeDegree / max(nodeDegree))).^12;

% Set point color to yellow with transparency
pointColor = [0, 1, 0]; % Yellow color with 
p.NodeColor = pointColor;
p.EdgeAlpha = 0.5;

% Create a UI figure to display the table
figureTitle = sprintf('Degree of Connection (Threshold: %.2f)', correlationThreshold);
f = uifigure('Name', figureTitle, 'Position', [100 100 300 250]);
t = uitable('Parent', f, 'Data', resultsTable, 'Position', [20 20 260 200]);
t.ColumnSortable(1) = true;
t.ColumnSortable(2) = true;

end
function [x, y, z] = spherePoints(n)
    % Generate n points distributed on the surface of a sphere
    theta = linspace(0, 2*pi, n);
    phi = acos(2 * linspace(0, 1, n) - 1);
    x = sin(phi) .* cos(theta);
    y = sin(phi) .* sin(theta);
    z = cos(phi);
end

function [x, y] = circlePoints(n)
    % Generate n points distributed on the circumference of a circle
    theta = linspace(0, 2*pi, n);  % n points evenly spaced around the circle

    % The radius of the circle is assumed to be 1 for simplicity
    % If you want a different radius, multiply x and y by the radius
    x = cos(theta);  % x coordinate
    y = sin(theta);  % y coordinate
end
