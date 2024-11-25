function hypergeometric_test
    % Create the figure window
    fig = uifigure('Position', [100 100 400 300], 'Name', 'Hypergeometric P-value Calculator');

    % Create labels and edit fields for inputs
    uilabel(fig, 'Position', [30 250 180 22], 'Text', 'Total Genes (M):');
    M_edit = uieditfield(fig, 'numeric', 'Position', [250 250 100 22], 'Value', 12327);

    uilabel(fig, 'Position', [30 200 180 22], 'Text', 'Genes in Set A:');
    N_human_edit = uieditfield(fig, 'numeric', 'Position', [250 200 100 22], 'Value', 1307);

    uilabel(fig, 'Position', [30 150 180 22], 'Text', 'Genes in Set B:');
    N_mouse_edit = uieditfield(fig, 'numeric', 'Position', [250 150 100 22], 'Value', 167);

    uilabel(fig, 'Position', [30 100 180 22], 'Text', 'Number of Overlapping Genes:');
    overlap_edit = uieditfield(fig, 'numeric', 'Position', [250 100 100 22], 'Value', 35);

    % Create a button to calculate the p-value
    calcButton = uibutton(fig, 'push', 'Position', [100 50 150 40], 'Text', 'Calculate P-value', ...
        'ButtonPushedFcn', @(calcButton,event) calculatePValue(M_edit.Value, N_human_edit.Value, N_mouse_edit.Value, overlap_edit.Value));

    % Create an editable field to display the result
    resultEdit = uieditfield(fig, 'text', 'Position', [30 20 270 22], 'Editable', 'on');

    % Callback function to calculate p-value and display result
    function calculatePValue(M, N_human, N_mouse, overlap)
        % Perform the hypergeometric test
        p_value = hygecdf(overlap-1, M, N_human, N_mouse, 'upper');
        % Display the result in the editable text field
        resultEdit.Value = num2str(p_value);
        % Display the result
    disp(['The hypergeometric p-value is: ', num2str(p_value)]);
    end
end
