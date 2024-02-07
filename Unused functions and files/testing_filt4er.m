% Example cell array with 1000 cells
geneCell = cell(1000, 1);
% for i = 1:1000
%     geneCell{i} = sprintf('Ans=%d,Bgh=%d,C=%d', randi([1, 10]), randi([1, 10]), randi([1, 10]));
% end
fig = figure;

global ax
ax = geoaxes("Basemap", "satellite");
data=load('house4.mat');
% Variables to check
desiredVariables = {'And','Bgh'};
houseLat=data.latitude;
houseLon=data.longitude;
for i = 1:length(data.gene)
    variableExists = all(contains(data.gene{1,i}, 'B'), 2);
    if variableExists
      geoplot(ax, houseLat(i), houseLon(i), 'o',  'MarkerSize', 10, 'MarkerFaceColor', [0,1,1], 'MarkerEdgeColor', 'black');
      display(i)
    end
end
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
% Convert cell array to a string array
% geneStrings = string(geneCell);
% 
% % Check if each desired variable exists in each string
% % variableExists = contains(geneStrings, desiredVariables);
% variableExists = all(contains(geneStrings, desiredVariables), 2);
% % Find the index of the first occurrence
% firstOccurrenceIndex = find(variableExists, 1);
% variableExists = all(contains(split(geneStrings, ','), desiredVariables), 2);

% Display the results
% for i = 1:numel(geneCell)
%     fprintf('In row %d, variables %s exist.\n', i, strjoin(desiredVariables(variableExists(i,:)), ', '));
% end