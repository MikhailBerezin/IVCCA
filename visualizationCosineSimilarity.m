% Step 1: Generate two random matrices
A = rand(10);  % Random matrix of size 10x10
B = rand(10);  % Another random matrix of size 10x10

% Convert them to correlation matrices
R1 = corrcoef(A);
R2 = corrcoef(B);

% Step 2: Flatten and calculate cosine similarity
flatR1 = R1(:);  % Flatten the matrix
flatR2 = R2(:);  % Flatten the matrix

cos_sim = dot(flatR1, flatR2) / (norm(flatR1) * norm(flatR2));

% Visualization
figure;

% Subplot 1: Heatmap of the first correlation matrix
subplot(1,3,1);
imagesc(R1);  % creates a heatmap from the first correlation matrix
title('Correlation Matrix A');
colorbar; % add colorbar for reference

% Subplot 2: Heatmap of the second correlation matrix
subplot(1,3,2);
imagesc(R2);  % creates a heatmap from the second correlation matrix
title('Correlation Matrix B');
colorbar; % add colorbar for reference

% Subplot 3: Bar graph showing the cosine similarity
subplot(1,3,3);
bar(1, cos_sim, 'r');  % Creates a red bar graph with one bar for cosine similarity
title('Cosine Similarity between Matrices');
xlabel('Matrix Pair');
ylabel('Cosine Similarity');
ylim([0 1]); % Assuming similarity will be between 0 and 1
text(1, cos_sim, num2str(cos_sim), 'vert', 'bottom', 'horiz', 'center');  % Displays the value on the bar
