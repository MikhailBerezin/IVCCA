% Create a figure and a map axes
fig = figure;

global ax
ax = geoaxes("Basemap", "satellite");
hold on
global viewOptions
viewOptions= {'satellite','grayterrain', 'colorterrain', 'landcover', 'streets'};
currentOption = 2;
nameButton = uicontrol('Style', 'pushbutton', 'String', 'Enter Name',...
    'Position', [.0500 .050 .150 .10], 'Callback', @highlightHouses);
% geobasemap(ax, viewOptions{1});
% hold on
% Create a pop-up menu
% figure(fig)
popup = uicontrol('Style', 'popupmenu', 'String', viewOptions, ...
    'Position', [100 20 200 20], 'Callback', @updateMapView);
% Define the coordinates of the houses
% 38.6640896, -90.3675212; 38.6640843, -90.3674125
houseCoordinates = [38.51311, -90.43595;38.6640896, -90.3675212]; % Add more coordinates as needed

numHouses = size(houseCoordinates, 1);
global houseLat
global houseLon
global data
% Initialize arrays for storing house data
% houseLat = houseCoordinates(:, 1);
% houseLon = houseCoordinates(:, 2);
data=load('new_data.mat');
houseLat=data.latitude;
houseLon=data.longitude;
global people
people = data.house_hold;


% Define the coordinates of the houses
% 38.6640896, -90.3675212; 38.6640843, -90.3674125
houseCoordinates = [38.51311, -90.43595;38.6640896, -90.3675212]; % Add more coordinates as needed
numHouses = size(houseCoordinates, 1);
global houseLat
global houseLon
global gene
% Initialize arrays for storing house data
numHouses=length(people);
% houseLat = houseCoordinates(:, 1);
% houseLon = houseCoordinates(:, 2);
global people
% people = cell(numHouses, 1);
% gene=data.biomarkers;
% Initialize an array to store the plot handles
housePlots = cell(numHouses, 1);
% houseNames = cell(numHouses, 1);
% Set the initial view option

% Function to update the GeoAxes view


% Loop over each house
for i = 1:numHouses
    
    % Plot the house location on the map
    color = rand(1, 3); % Generate a random RGB color for each house
    housePlots{i} = geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 10, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'black');
%     houseNames{i} = ['House ' num2str(i)];
end

% Create a legend
% legend(housePlots, houseNames, 'Location', 'bestoutside');

% Display the house locations
disp('House Locations:')
disp(table(houseLat, houseLon));

% Create a database listing the people in each house
% houseDatabase = table(people, 'VariableNames', {'People'});
% disp('House Database:')
% disp(houseDatabase);

% Set up a text annotation object for displaying the names
textAnnotation = text(0, 0, '', 'Color', 'white', 'FontSize', 8, 'Visible', 'off');

% Add a callback function to display names when clicking on a point
% set(fig, 'WindowButtonDownFcn', @showNames);
dcm_obj = datacursormode(fig);
% set(fig, 'WindowButtonDownFcn', @showNames);
set(dcm_obj, 'UpdateFcn', @showNames);

% Adjust the map view to include all houses
latMargin = 0.1 * range(houseLat); % Add a margin of 10% to the latitude range
lonMargin = 0.1 * range(houseLon); % Add a margin of 10% to the longitude range

% Check if latitude values exceed the valid range and adjust accordingly
if any(houseLat > 90)
    houseLat(houseLat > 90) = 90;
end
if any(houseLat < -90)
    houseLat(houseLat < -90) = -90;
end

latLim = [min(houseLat) - latMargin, max(houseLat) + latMargin];
lonLim = [min(houseLon) - lonMargin, max(houseLon) + lonMargin];
% geolimits(ax, latLim, lonLim);

% Set a title for the map
titleText = 'Initial Title';

function updateMapView(source, ~)
global viewOptions
global ax
    currentOption = get(source, 'Value');
    geobasemap(ax, viewOptions{currentOption});
end

function output_txt = showNames(~, event_obj)
    global people
    global ax
    global houseLat
    global houseLon
    global data
    global housePlots
    point = event_obj.Position;
%     point = event_obj.IntersectionPoint(1:2);
    lat = point(1);
    lon = point(2);
    lon2 = find(houseLon==lon);
    lat2 = find(houseLat==lat);
    if lon2==lat2
        pointIndex=lat2;
    end
    % Find the closest house based on the clicked point
%     distances = sqrt((lat - houseLat).^2 + (lon - houseLon).^2);
%     [~, pointIndex] = min(distances);
    
    if ~isempty(pointIndex)
        members = data.members{1,pointIndex};
        peopleNames1 = people{pointIndex};
        members2=string(members);
        members2=strcat(members2(1),',',members2(2));
        peopleNames = string(peopleNames1);
        if ~isempty(peopleNames)
%             name=data.members{1,pointIndex};
             delimiter = ' '; % Specify the delimiter between elements
%             gene =strjoin(gene, delimiter);
%             gene=cellstr(gene);
%               namesStr1 = sprintf('last name:%s', peopleNames1,'\n');
              namesStr = sprintf(strcat(peopleNames,'\n',members2));
            
%              value=data.data.values{pointIndex};
        else
            namesStr = 'No people in this house.';
        end
        tableData = {};
%         gene=data.data.gene{pointIndex};
        m=1;
        for i=1:length(members)
            
           %get biomarkers for the people
           k=data.biomarkers{i,pointIndex};
           p=table2array(k);
           
           final_ar= split(p{1},',');
           
           for j=1:length(final_ar)
               final_ar2=split(final_ar{j},'=');
               
               tableData{m, 1} = members{i,1};
               tableData{m, 2} = ((final_ar2{1,1}));
               tableData{m, 3} = ((final_ar2{2,1}));
               m=m+1;
           end
           
           
           
          
        end
        resultTable = cell2table(tableData, 'VariableNames', {'Name', 'Genename' ,'Value'});

% Create a uifigure with a dynamic title that includes the threshold
        figTitle = sprintf('%s"s Table of gene',peopleNames{1} );
        fig = uifigure('Position', [50, 200, 500, 300], 'Name', figTitle, 'Icon','Corr_icon.png');

        % Create a uitable in the uifigure with the sorted data
        uit = uitable(fig, 'Data', table2cell(resultTable), 'ColumnName', {'Name', 'Genename' ,'Value'}, 'Position', [20, 20,450, 280]);
        output_txt = {namesStr};
        % Update the text annotation
        textAnnotation.String = namesStr;
        textAnnotation.Position = point;
        textAnnotation.Visible = 'on';
    else
        output_txt = '';
    end
    
end


function highlightHouses(~, ~)
    global numHouses
    global people
    global houseLat
    global houseLon
    global housePlots
    global ax
    
    % Ask the user for a name
    prompt = {'Enter a name:'};
    title = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt, title, dims);
    
    if ~isempty(answer)
        % Extract the name
        name = answer{1};
        
        % Variables to store the found house number(s)
        foundHouses = [];
        
        % Loop over each house
        for i = 1:length(people)
            % Check if the name is in the list of people for the house
            if any(strcmp(people{i}, name))
                % If the name is found, highlight the house
                housePlots(i) = geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 30, 'MarkerFaceColor', 'green', 'MarkerEdgeColor', 'black');
                foundHouses = [foundHouses i]; % Store the found house number

                houseNames{i} = ['House ' num2str(i)];
            else
              % housePlots{i}.MarkerFaceColor = [0 0 1]; % Reset color
                housePlots(i) = geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 10, 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'black');
            end
        end
        
        % Display message boxes based on the foundHouses array
        if ~isempty(foundHouses)
            % Convert the array of found house numbers to a string
            houseNumbers = num2str(foundHouses);
            msg = sprintf('The house(s) with the name "%s" is found.\nHouse Number(s): %s', name, houseNumbers);
        else
            msg = sprintf('The house with the name "%s" is not found.', name);
        end
        
        msgbox(msg, 'House Search Result');
    end
end
function highlightHouses2(~, ~)
    global numHouses
    global people
    global houseLat
    global houseLon
    global housePlots
    global ax
    
    % Ask the user for a name
    prompt = {'Enter a name:'};
    title = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt, title, dims);
    
    if ~isempty(answer)
        % Extract the name
        name = answer{1};
        
        % Variables to store the found house number(s)
        foundHouses = [];
        
        % Loop over each house
        for i = 1:length(people)
            % Check if the name is in the list of people for the house
            if any(strcmp(people{i}, name))
                % If the name is found, highlight the house
                housePlots(i) = geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 30, 'MarkerFaceColor', 'green', 'MarkerEdgeColor', 'black');
                foundHouses = [foundHouses i]; % Store the found house number

                houseNames{i} = ['House ' num2str(i)];
            else
              % housePlots{i}.MarkerFaceColor = [0 0 1]; % Reset color
                housePlots(i) = geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 10, 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'black');
            end
        end
        
        % Display message boxes based on the foundHouses array
        if ~isempty(foundHouses)
            % Convert the array of found house numbers to a string
            houseNumbers = num2str(foundHouses);
            msg = sprintf('The house(s) with the name "%s" is found.\nHouse Number(s): %s', name, houseNumbers);
        else
            msg = sprintf('The house with the name "%s" is not found.', name);
        end
        
        msgbox(msg, 'House Search Result');
    end
end

