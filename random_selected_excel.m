% Load the Excel file
filename = 'C:\Users\berezinm\Dropbox\Papers\2023 Correlation paper\Heart\Heart 13795 no FDR.xlsx'; % Replace with your file name
opts = detectImportOptions(filename);
data = readtable(filename, opts);

% Ensure there are enough columns to select 1744
if width(data) < 1744
    error('The file does not have enough columns.');
end

% Randomly select 1744 columns
selectedColumns = randsample(width(data), 1744);
selectedData = data(:, selectedColumns);

% Save the selected columns to a new Excel file
% This will keep the column names in the first row
outputFilename = 'random_1744.xlsx';
writetable(selectedData, outputFilename);
