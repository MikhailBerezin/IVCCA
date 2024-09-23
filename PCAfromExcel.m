% Load the data from Excel file
filename = 'DRG vs Heart.xlsx'; % replace with your Excel file name

data = readtable(filename);

% Convert table to array, handling mixed types
numericData = [];
for i = 1:width(data)
    if iscell(data{:,i})
        % Attempt to convert cell array to numeric if possible
        numData = str2double(data{:,i});
        if all(~isnan(numData))
            numericData = [numericData, numData]; %#ok<*AGROW>
        else
            warning('Column %d contains non-numeric data and will be excluded.', i);
        end
    elseif isnumeric(data{:,i})
        numericData = [numericData, data{:,i}];
    else
        warning('Column %d contains unsupported data type and will be excluded.', i);
    end
end

% Check if numericData is not empty
if isempty(numericData)
    error('No numeric data available for PCA analysis.');
end

% Normalize the data (optional but recommended)
dataNormalized = normalize(numericData);

% Perform PCA
[coeff, score, latent, tsquared, explained, mu] = pca(dataNormalized);

% Display the results
disp('Principal Components:');
disp(coeff);

disp('Scores:');
disp(score);

disp('Explained Variance:');
disp(explained);

% Plot the explained variance
figure;
pareto(explained);
title('Explained Variance by Principal Components');

% Scatter plot of the first two principal components
figure;
scatter(score(:,1), score(:,2));
xlabel('First Principal Component');
ylabel('Second Principal Component');
title('PCA Score Plot');
grid on;
