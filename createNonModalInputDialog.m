function createNonModalInputDialog()
    % Create a figure for the dialog
    fig = uifigure('Name', 'Input', 'Position', [100, 100, 300, 150], 'Icon','Corr_icon.png');
    fig.WindowStyle = 'normal'; % Make it non-modal

    % Create an edit field for input
    lbl = uilabel(fig, 'Position', [10, 120, 280, 20], 'Text', 'Enter the number of entries for plotting:');
    ef = uieditfield(fig, 'numeric', 'Position', [10, 90, 280, 22]);

    % Create a button to submit the input
    btn = uibutton(fig, 'Position', [100, 50, 100, 22], 'Text', 'Submit');
    btn.ButtonPushedFcn = @(btn, event) submitInput(ef, fig);
end