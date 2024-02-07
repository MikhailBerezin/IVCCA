% Read the gene lists from files
file1 = 'C:\Users\berezinm\Dropbox (Personal)\Papers\2023 Correlation paper\Top100.txt';  % Path to the first gene list file
file2 = ['C:\Users\berezinm\Dropbox (Personal)\Papers\2023 Correlation paper\Cluster_8' ...
    '.txt'];  % Path to the second gene list file

genes1 = readGeneList(file1);
genes2 = readGeneList(file2);

% Compare the gene lists
commonGenes = intersect(genes1, genes2);

% Display the common genes
disp('Common Genes:');
disp(commonGenes);

% Function to read gene list from file
function genes = readGeneList(filename)
    fileID = fopen(filename, 'r');
    geneStr = fgetl(fileID);
    genes = strsplit(geneStr, ',');
    fclose(fileID);
end