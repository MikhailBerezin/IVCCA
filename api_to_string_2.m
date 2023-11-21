% Specify the URL and method
string_api_url = 'https://version-11-5.string-db.org/api';
output_format = 'image';
method = 'network';

% List of genes
my_genes = {'YMR055C', 'YFR028C', 'YNL161W', 'YOR373W', 'YFL009W', 'YBR202W'};

% Loop through each gene
for i = 1:length(my_genes)
    % Set parameters
    params = struct('identifiers', my_genes{i}, ...
                    'species', 4932, ...
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
end
