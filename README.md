The `InterCorrelation` function in MATLAB creates a graphical user interface (GUI) for correlation analysis for genes but also for other datasets. The GUI allows you to load data, calculate the correlation matrix, sort the matrix, visualize it as a heatmap, and perform clustering analysis. Here is a summary of what the software does:

1. The function creates a GUI window with buttons, a table, and graphs.
2. The "Load Data" button allows you to select an Excel or CSV file containing the data.
3. After loading the data, the "Calculate Correlations" button becomes enabled, allowing you to compute the correlation matrix.
4. The correlation matrix is displayed in a table within the GUI, and the table is editable.
5. Once calculated, you can enable the "Sort" button to sort the correlation matrix based on the magnitudes of the correlations.
6. The "Graph" button enables you to visualize the correlation matrix as a heatmap.
7. The "Dendrogram" button performs hierarchical clustering after selection a threshold on the correlation matrix and displays a dendrogram.
8. 

8. The software provides tooltips for each button, giving additional information.
9. The GUI includes error handling for incorrect data formats or insufficient columns in the loaded file.

To use the software, you can follow these steps:
1. Start the GUI_correlation.
2. The GUI window will appear.
4. Click the "Load Data" button and select an Excel or CSV file containing your data. The first raw should have the header (i.e. gene name)
5. Once the data is loaded, click the "Calculate" button to compute the correlation matrix.
6. Enable the "Sort" button if you wish to sort the correlation matrix based on magnitudes.
7. Click the "Graph" button to visualize the correlation matrix as a heatmap.
8. To perform hierarchical clustering, click the "Cluster" button and select the color threshold and a dendrogram with colored clusters will be displayed.
