% Author : Hridoy


%%
function api_to_string_3(varargin)
stringApiUrl = 'https://version-11-5.string-db.org/api';
outputFormat = 'tsv-no-header';
method = 'network';

% Construct URL
requestUrl = strcat(stringApiUrl, '/', outputFormat, '/', method);

% Set parameters
my_genes = {'CDC42','KIF23','PLK1'};
% my_genes=(getappdata(0,'genes'));
if isa(my_genes,'char')
    
   my_genes = strsplit(my_genes, ',');
end


species = 9606;
callerIdentity = 'www.awesome_app.org';
% my_genes = {'CDC42'}
% for i = 1:length(my_genes)
identifiers = strjoin(my_genes, '%0d');
% identifiers = my_genes{i};
% Construct data structure
params = {'identifiers', identifiers, 'species', num2str(species), 'caller_identity', callerIdentity};

% Call STRING
response = webwrite(requestUrl, params{:}, 'RequestMethod', 'post');

% Split and process the response
lines = strsplit(response, '\n');

% Create a file to write the results
outputFileName =strcat(my_genes{1},'filtered_interactions.txt');
fileID = fopen(outputFileName, 'w');

for i = 1:numel(lines)
    currentLine = strsplit(strtrim(lines{i}), '\t');
    
    % Check if there are enough elements in the line
    if numel(currentLine) >= 11
        p1 = currentLine{3};
        p2 = currentLine{4};
        
        % Filter the interaction according to experimental score
        experimentalScore = str2double(currentLine{11});
        if experimentalScore > 0.3
            % Write to the file
            fprintf(fileID, '%s\t%s\texperimentally confirmed (prob. %.3f)\n', p1, p2, experimentalScore);
        end
    end
end
fclose(fileID);
disp(['Filtered interactions written to ', outputFileName]);
% end
% Close the file

end