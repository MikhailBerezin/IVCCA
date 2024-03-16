
%Random columns from excell data
 
% data = xlsread('C:\Users\berezinm\Dropbox (Personal)\Papers\2023 Correlation paper\Heart\Heart 13795 no FDR.xlsx');
% Load the Excel file using xlsread
[num, txt, raw] = xlsread('C:\Users\berezinm\Dropbox (Personal)\Papers\2023 Correlation paper\Heart\Heart 13795 no FDR.xlsx');

% Get the column names
columnNames = raw(1, :);

% Remove the first row (column names) from the raw data
raw(1, :) = [];

% Determine the total number of columns in the loaded data
numColumns = size(raw, 2);

% Generate a random index vector of size 1744, representing the randomly selected column indices
selectedIndices = datasample(1:numColumns, 1744, 'Replace', false);

% Select the columns corresponding to the randomly chosen indices, including the first row (column names)
selectedData = [columnNames; raw(:, selectedIndices)];

% Save the selected data as a new Excel file using xlswrite
xlswrite('random_1744.xlsx', selectedData);