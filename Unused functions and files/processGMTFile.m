%  filePath = 'C:/Users/berezinm/Dropbox/Papers/2023 Correlation paper/Pathways/GO pathways/Renamed GO files/filtered.gmt';
% 
%  processGMTFile(filePath);

function processGMTFile(filePath)
    % Check if the file exists
    if ~exist(filePath, 'file')
        error('File does not exist: %s', filePath);
    end

    % Open the GMT file
    fid = fopen(filePath, 'r');
    
    if fid == -1
        error('Cannot open file %s', filePath);
    end

    % Extract the directory path from the file path
    [pathStr, ~, ~] = fileparts(filePath);

    % Define the chunk size (number of lines to read at a time)
    chunkSize = 100;  % Adjust based on your needs and memory constraints

    while ~feof(fid)
        % Initialize a cell array to hold lines from the file
        lines = cell(chunkSize, 1);
        count = 0;

        % Read lines in chunks
        while ~feof(fid) && count < chunkSize
            count = count + 1;
            lines{count} = fgets(fid);
        end

        % Process each line in the chunk
        for k = 1:count
            line = lines{k};
            parts = strsplit(line, '\t');
            
            % Check if the number of genes is more than 100
            if length(parts) <= (2 + 100)
                continue;
            end

            pathwayName = sanitizeFileName(parts{1});
            pathwayFileName = fullfile(pathStr, sprintf('%s.txt', pathwayName));

            if numel(pathwayFileName) >= 260
                warning('File path is too long: %s', pathwayFileName);
                continue;
            end

            pathwayFile = fopen(pathwayFileName, 'w');
            if pathwayFile == -1
                warning('Cannot create file %s', pathwayFileName);
                continue;
            end

            for i = 3:length(parts)
                fprintf(pathwayFile, '%s\n', strtrim(parts{i}));
            end

            fclose(pathwayFile);
        end
    end
    
    fclose(fid);
end
function sanitizedFileName = sanitizeFileName(fileName)
    % Replace invalid file name characters with an underscore
    invalidChars = {'/', '\', ':', '*', '?', '"', '<', '>', '|'};
    sanitizedFileName = fileName;
    for i = 1:length(invalidChars)
        sanitizedFileName = strrep(sanitizedFileName, invalidChars{i}, '_');
    end
end
