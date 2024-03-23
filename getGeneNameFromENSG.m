function geneName = getGeneNameFromENSG(ensgId, excelFilePath)
    % Query an Excel file and then Ensembl REST API to get the gene name for a given ENSG number.
    %
    % Parameters:
    % - ensgId: The Ensembl Gene ID (e.g., 'ENSG00000139618').
    % - excelFilePath: The path to the Excel file containing ENSG IDs and gene names.
    %
    % Returns:
    % - geneName: The gene name if found, otherwise 'Not found'.

    % Try to find the ENSG ID in the Excel file first
    try
        % Assuming the first column contains ENSG IDs and the second contains gene names
        tbl = readtable('geneNameFromENSG.xlsx', 'ReadVariableNames', false);
        idx = find(strcmp(tbl.Var1, ensgId));
        
        if ~isempty(idx)
            geneName = tbl.Var2{idx};
            fprintf('ENSG ID: %s = %s (found in Excel file)\n', ensgId, geneName);
            return;
        end
    catch ME
        fprintf('Failed to read Excel file: %s\n', ME.message);
        % Continue to try to fetch the gene name from the server
    end

    % If not found in the Excel file, query the Ensembl REST API
    server = 'https://rest.ensembl.org';
    ext = sprintf('/lookup/id/%s?content-type=application/json', ensgId);
    url = [server ext];
    
    % Increase the timeout to 60 seconds (or more, if needed)
    options = weboptions('ContentType', 'json', 'Timeout', 60);
    
    try
        data = webread(url, options);
        if isfield(data, 'display_name')
            geneName = data.display_name;
            fprintf('ENSG ID: %s = %s (found on server)\n', ensgId, geneName);
        else
            geneName = 'Not found';
            fprintf('ENSG ID: %s is not found on server.\n', ensgId);
        end
    catch
        geneName = 'Not found';
        fprintf('Failed to fetch data for ENSG ID: %s from server.\n', ensgId);
    end
end