% Specify the URL and method

function api_to_string_2(varargin)
string_api_url = 'https://version-11-5.string-db.org/api';
output_format = 'image';
method = 'network';

% List of genes
% my_genes = {'Adrb1', 'YFR028C', 'YNL161W', 'YOR373W', 'YFL009W', 'YBR202W'};
my_genes=getappdata(0,'genes');
if isa(my_genes,'char')
    
   my_genes = strsplit(my_genes, ',');
end
    
% Loop through each gene

for i = 1:length(my_genes)
    try
    % Set parameters
    params = struct('identifiers', my_genes{i}, ...
                    'species', 10090, ...
                    'add_white_nodes', 15, ...
                    'network_flavor', 'confidence', ...
                    'caller_identity', 'www.awesome_app.org');
    
    % Construct the request URL
    request_url = [string_api_url, '/', output_format, '/', method];
    
    % Convert params to a query string
    query_str = '';
    param_names = fieldnames(params);
    for j = 1:length(param_names)
        param_name = param_names{j};
        param_value = params.(param_name);
        query_str = [query_str, '&', param_name, '=', num2str(param_value)];
    end
    
    % Remove the leading '&' character
    query_str = query_str(2:end);
    
    % Make the HTTP POST request
    options = weboptions('MediaType', 'auto', 'RequestMethod', 'post');
    response = webwrite(request_url, query_str, options);
    
    % Save the network to a file
    file_name = [my_genes{i}, '_network.jpeg'];
    disp(['Saving interaction network to ', file_name]);
%     fid = fopen(file_name, 'wb');
    imwrite(response, file_name)
%     fwrite(fid, response);
%     fclose(fid);
    
    % Pause for 1 second
    pause(1);
    catch
    disp(['SNot found ', my_genes{i}]);
    end
    

end

end
