% Your list of genes
genes = {'BRCA1', 'TP53', 'EGFR', 'TNF', 'GAPDH'};  % Example gene list

% Convert the list of genes to a comma-separated string
geneList = strjoin(genes, '%0d');

% Define the STRING API URL for protein-protein interaction query
apiUrl = 'https://string-db.org/api/'; 
outputFormat = 'json';  % Output format: json, tsv, etc.
method = 'network';     % Method: network, enrichment, etc.
species = '10090';       % NCBI Taxonomy identifier for mus musculus

% Construct the full URL for the request
requestUrl = sprintf('%s%s/%s?identifiers=%s&species=%s', apiUrl, outputFormat, method, geneList, species);

% Send the HTTP GET request
response = webread(requestUrl);

% Process the response as needed
% The response is a struct array if the output format is json.
% You can access the data as follows:
% for i = 1:length(response)
%     disp(response(i).preferredNameA);
%     disp(response(i).preferredNameB);
%     disp(response(i).score);
% end


% Your list of genes
genes = {'BRCA1', 'TP53', 'EGFR', 'TNF', 'GAPDH'};  % Example gene list

% Convert the list of genes to a comma-separated string
geneList = strjoin(genes, '%0D');

% Define the STRING URL for visualizing interactions
baseStringUrl = 'https://string-db.org/cgi/input.pl?';
outputFormat = 'json';  % Output format: json, tsv, etc.
method = 'network';     % Method: network, enrichment, etc.
species = '10090';  % NCBI Taxonomy identifier for Homo sapiens (human)
additionalParams = 'network_type=functional&identifiers='; % Additional parameters

% Construct the full URL
fullUrl = [baseStringUrl additionalParams geneList '%0D' '&species=' species];

% Open the URL in a web browser
web(fullUrl, '-browser');
