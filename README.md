The `IVCCA` platform was developed in Berezin Lab at Washington University School of Medicine in 2023-2024 in MATLAB. 
The platform creates a graphical user interface (GUI) for comprehensive correlation analysis for genes and other datasets. 
The GUI allows you to load data, calculate the correlation matrix, sort the matrix, visualize it as a heatmap, and perform clustering analysis, 
compare genes and pathways and perform network analysis. Here is a summary of what the software does:

1. The function creates a GUI window with buttons, a table, and graphs.
2. The "Load Data" button allows you to select an Excel or CSV file containing the data.
3. After loading the data, the "Correlation" button becomes enabled, allowing you to compute the correlation matrix.
4. The correlation matrix is displayed in a table within the GUI, and the table is editable.
5. Once calculated, you can enable the 'Sort' button to sort the correlation matrix based on the magnitudes of the correlations.
6. The "Sorted Graph" button enables you to visualize the correlation matrix as a heatmap.
7. The "Elbow/Silhouette" button enables you to calculate the optimal number of clusters.
7. The "Dendrogram" button performs hierarchical clustering after selection a threshold on the correlation matrix and displays a dendrogram.
8. The PCA button open a toolbox for clustering and gene/pathways visualizations.
9. The Single Pathway button enables visualization correlations between the genes within a single set of genes (pathway).
10. The MultiPathway button calculates the ranking of many functions based on the correlation of each gene inside the pathway
11. The "Gene To Genes" button calculates the correlation between a single gene and other genes.
12. The "Gene To Pathways" button calculates the correlation between a single gene and many pathways.
13. The "Compare Pathways" button enables selection of two or multiple pathways and calculate a cosine similarity between them.
14. The "Venn diagram" button enables selection of two pathways to generate Venn diagram. 
15. The "Network analysis" button enables generating a pathway to generate either a 2D ot 3D network graph.  


To use the software, you can follow these steps:
1. Start the GUI_correlation.
2. The GUI window will appear.
4. Click the "Load Data" button and select an Excel, CSV or TSV file containing your data. 
The first raw should have the header (i.e. gene names), the first column should be the names of the sample. All other fields should be numerical 
5. Once the data is loaded, click the "Correlation" button to compute the correlation matrix.
6. Other buttons will be activated. 

Detailed manual will be uploaded in Spring 2024.

Cite: Junwei Du; Leland C. Sudlow; Hridoy Biswas; Joshua D. Mitchell; Shamim Mollah; Mikhail Y. Berezin, Identification Drug Targets for Oxaliplatin-Induced Cardiotoxicity without affecting cancer treatment through Inter Variability Cross-Correlation Analysis (IVCCA), BIORXIV/2024/579390 