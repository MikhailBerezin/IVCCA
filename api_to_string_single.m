function api_to_string_single(varargin)
string_api_url = 'https://version-11-5.string-db.org/api';
output_format = 'image';
method = 'network';

global selectedGene;
% Retrieve the selected gene name
selectedGene = getappdata(0, 'selectedGene');

if isempty(selectedGene)
    h = msgbox('No gene selected. Please select a gene.');
      iconFilePath = fullfile('Corr_icon.png');
    setIcon(h, iconFilePath);
    return;
end

try
    % Set parameters for the selected gene
    params = struct('identifiers', selectedGene, ...
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

    % Construct the full URL
    full_url = [request_url, '?', query_str];

    % Make the HTTP GET request
    options = weboptions('ContentType', 'image');
    response = webread(full_url, options);

    % Display the image
   string_fig = figure('Name', ['STRING results for ' selectedGene], 'NumberTitle', 'off');
      iconFilePath = fullfile('Corr_icon.png');
    setIcon(string_fig, iconFilePath);
    imshow(response);
    box off
    % Remove ticks
            % set(gca, 'XTick', [], 'YTick', []);
            
            %  to remove the axis lines entirely:
             axis off;
    
catch e
   h = msgbox(['Error processing gene: ', selectedGene, '. Details: ', e.message]);
     iconFilePath = fullfile('Corr_icon.png');
    setIcon(h, iconFilePath);
end

end
