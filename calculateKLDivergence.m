function klValue = calculateKLDivergence(data, Y, sigma)

sigma = getappdata(0, 'perplexityValue'); 
data =  getappdata(0, 'correlations');
Y =  getappdata(0, 'Y');

    % Calculate the original distribution
    originalDistribution = calculateOriginalDistribution(data, sigma);

    % Calculate the t-SNE result distribution
    tsneResultDistribution = calculateTsneDistribution(Y, sigma);

    % Calculate KL Divergence
    klValue = KLDivergence(originalDistribution, tsneResultDistribution);


%  KL Divergence 
    function klDiv = KLDivergence(P, Q)
        % Ensure the vectors are of the same size
        assert(numel(P) == numel(Q), 'The distributions must have the same number of elements');
        
        % Normalize P and Q
        P = P / sum(P);
        Q = Q / sum(Q);

        % Indices where P is not zero
        nonzeroIdx = P > 0;

        % Calculate KL Divergence
        klDiv = sum(P(nonzeroIdx) .* log(P(nonzeroIdx) ./ Q(nonzeroIdx)));
    end

 function originalDistribution = calculateOriginalDistribution(data, sigma)
    % Transform correlation to a positive scale suitable for similarities  by inverting the correlation scores to represent distance
    distances = 1 - abs(data);  % Convert correlation to distance

    % Convert distances to similarities using a Gaussian-like kernel
    % Avoid squaring as these are not Euclidean distances
    similarities = exp(-distances / (2 * sigma^2));

    % Convert the similarity matrix to a probability matrix
    P_conditional = bsxfun(@rdivide, similarities, sum(similarities, 2));
    
    % Symmetrize to get joint probabilities
    P_joint = (P_conditional + P_conditional') / (2 * size(data, 1));

    originalDistribution = P_joint; % This is the distribution to use for KL divergence
end

function tsneResultDistribution = calculateTsneDistribution(Y, sigma)
    % Calculate pairwise Euclidean distances of Y
    squareDist = pdist2(Y, Y).^2;
    
    % Convert distances to similarities using Gaussian kernel
    similarities = exp(-squareDist / (2 * sigma^2));
    
    % Convert similarities to conditional probabilities
    Q_conditional = bsxfun(@rdivide, similarities, sum(similarities, 2));
    
    % Symmetrize to get joint probabilities
    Q_joint = (Q_conditional + Q_conditional') / (2 * size(Y, 1));

    tsneResultDistribution = Q_joint;
end

   % Convert klValue to string for displaying
klValueStr = num2str(klValue);

% Display the KL divergence value in a message box

% msgbox(['The KL Divergence value is: ', klValueStr], 'KL Divergence');
% Creating a table with the results
resultsTable = table(sigma, klValue, 'VariableNames', {'Sigma', 'KL_Divergence'});

% Displaying the table
disp(resultsTable);

end
