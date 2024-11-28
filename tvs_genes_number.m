% Open a dialog to select the TVS file
[filename, pathname] = uigetfile('*.tsv', 'Select the TSV File');

% Check if a file was selected
if isequal(filename, 0)
    disp('File selection canceled.');
else
    % Full path to the selected file
    fullpath = fullfile(pathname, filename);

    % Open the file for reading
    fid = fopen(fullpath, 'r');

    % Check if the file was opened successfully
    if fid == -1
        error('Failed to open the file.');
    end

    % Initialize a counter for the genes
    geneCount = 0;

    % Read the file line by line
    while ~feof(fid)
        line = fgetl(fid); % Read a line
        if ischar(line)
            % Assuming each line corresponds to a gene entry
            geneCount = geneCount + 1;
        end
    end

    % Close the file
    fclose(fid);

    % Display the number of genes
    fprintf('The number of genes in the file is: %d\n', geneCount);
end
