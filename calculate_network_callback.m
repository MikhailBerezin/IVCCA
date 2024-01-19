function calculate_network_callback(~, ~, f)
    f.WindowStyle = 'normal';
   
    % Retrieve correlation data and variable names (gene names)
    cor_data = abs(getappdata(0, 'correlations'));
    geneNames = getappdata(0, 'variable_names');

    % Define a persistent variable to remember the last folder path
    persistent lastPath;
    
    % Ask the user if they want to filter the gene set
    choice = uiconfirm(f, 'Would you like to filter for the gene set (optional)?', 'Open Gene List', ...
                       'Options', {'Yes', 'No'}, 'DefaultOption', 1, 'CancelOption', 2);

    if strcmp(choice, 'Yes')
        % User chooses to filter for the gene set
        if isempty(lastPath) || ~exist(lastPath, 'dir')
            % If lastPath is empty or does not exist, start in the current directory
            lastPath = pwd;
        end
        [file, path] = uigetfile(fullfile(lastPath, '*.txt'), 'Select the file with the gene list');
        if isequal(file, 0)
            disp('User selected Cancel');
            return;
        else
            disp(['User selected ', fullfile(path, file)]);
            % Update lastPath with the current path
            lastPath = path;
            
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
    answer = inputdlg_id(prompt, dlgtitle, dims, definput);

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
    G = graph(filteredCorData, geneNames, 'OmitSelfLoops','Upper');

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

% Ask the user to choose between 2D and 3D plot
    plotChoice = questdlg('Choose the network plot type:', ...
                          'Network Plot Type', ...
                          '2D', '3D', '2D'); % Default to 2D


if strcmp(plotChoice, '2D')
            % Plot the network in 2D with nodes on a circle
               fig_2d =  figure ('Name','3D Network plot','NumberTitle','off'); % Open a new figure
               iconFilePath = fullfile('Corr_icon.png');
            setIcon(fig_2d, iconFilePath);
            [x, y] = circlePoints(numNodes);
            p = plot(G, 'XData', x, 'YData', y,...
                'EdgeColor',[0.0745098039215686 0.623529411764706 1],...
                'NodeColor',[1 0.0745098039215686 0.650980392156863],...
                'NodeFontSize',16);
            
            % Remove box around the plot
            box off;
            
            % Remove ticks
            set(gca, 'XTick', [], 'YTick', []);
            
            %  to remove the axis lines entirely:
             axis off;
    elseif strcmp(plotChoice, '3D')
            % Plot the network in 3D with nodes on a sphere

           fig_3d =  figure ('Name','3D Network plot','NumberTitle','off'); % Open a new figure
               iconFilePath = fullfile('Corr_icon.png');
            setIcon(fig_3d, iconFilePath);
               
            % Generate spherical coordinates for each node
            [x, y, z] = spherePoints(numNodes);            
           
            p = plot(G, 'XData', x, 'YData', y, 'ZData', z,...
                'EdgeColor',[0.0745098039215686 0.623529411764706 1],...
                'NodeColor',[1 0.0745098039215686 0.650980392156863],...
                'NodeFontSize',16);
         

             % Remove box around the plot
            box on;
            
            % Remove ticks
            % set(gca, 'XTick', [], 'YTick', []);
            
            %  to remove the axis lines entirely:
%              axis off;
    else
        % If the user closes the dialog or an unexpected value is returned
        disp('Plotting cancelled or invalid selection made.');
        return;
    end

% Parameters
threshold = 50.0; % Define a threshold for edge weights
maxWeight = max(G.Edges.Weight); % Find maximum edge weight
minLineWidth = 0.5; % Minimum line width for any edge above the threshold
maxLineWidth = 10; % Maximum line width

% Filter out edges below the threshold
filteredEdges = G.Edges.Weight >= threshold;

% Initialize LineWidth with zeros
lineWidths = zeros(size(G.Edges.Weight)); 

% Apply line width scaling only to edges above the threshold
for i = 1:length(filteredEdges)
    if filteredEdges(i)
        normalizedWeight = (G.Edges.Weight(i) / maxWeight);
        calculatedWidth = minLineWidth + (normalizedWeight * (maxLineWidth - minLineWidth)).^10;
        lineWidths(i) = max(calculatedWidth, minLineWidth); % Ensure at least minLineWidth
    end
end

% Debugging: Check if any lineWidths are non-positive
if any(lineWidths <= 0)
    disp('Non-positive line widths found. Adjusting to minimum line width.');
    lineWidths(lineWidths <= 0) = minLineWidth;
end

% Assign the calculated line widths to the plot
p.LineWidth = lineWidths;


% Adjust node size based on degree
p.MarkerSize = 10 + (1.5 * (nodeDegree / max(nodeDegree))).^10;

% Set point color to yellow with transparency
% pointColor = [0, 1, 0]; % Yellow color with 
% p.NodeColor = pointColor;
% p.EdgeAlpha = 0.5;

% Create a UI figure to display the table
figureTitle = sprintf('Degree of Connection (Threshold: %.2f)', correlationThreshold);
f = uifigure('Name', figureTitle, 'Position', [100 100 300 250], 'Icon','Corr_icon.png');
t = uitable('Parent', f, 'Data', resultsTable, 'Position', [20 20 260 200]);
t.ColumnSortable(1) = true;
t.ColumnSortable(2) = true;

end
function [x, y, z] = spherePoints(n)
    % Generate n points distributed on the surface of a sphere
    indices = 0:n-1;
    phi = acos(1 - 2*(indices+0.5)/n);
    theta = pi * (1 + sqrt(5)) * indices;

    x = cos(theta) .* sin(phi);
    y = sin(theta) .* sin(phi);
    z = cos(phi);
end

function [x, y] = circlePoints(n)
    % Generate n points distributed on the circumference of a circle
    theta = linspace(0, 2*pi, n+1);  % n+1 points around the circle
    theta(end) = [];  % Remove the last point to avoid overlap

    x = cos(theta);  % x coordinate
    y = sin(theta);  % y coordinate
end
