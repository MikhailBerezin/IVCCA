function venn_new_Gui_3(~, ~, f)
    % By Berezin Lab updated for 3 files
    global circleSeparation
   
    % Creating the figure at the beginning of your GUI code
    fig = uifigure('Name', 'IVCCA: Venn Diagram','Position', [100 100 700 400], 'Icon','Corr_icon.png');
    fig.WindowStyle = 'normal';
    
    % Store the figure handle somewhere accessible by the selectFile function
    mainGuiHandle = fig;

    % Create a grid layout
    gl = uigridlayout(fig, [4 4], 'ColumnWidth', {'1x', '1x', '1x', '1x'}, 'RowHeight', {'1x', '1x', '1x', '1x'});

    % Create properties for storing file paths
    filePaths = strings(3,1);
    fileNameLabels = gobjects(3,1);

    % Create buttons and labels for selecting files
    for i = 1:3
        btn = uibutton(gl, 'Text', ['Select File ' num2str(i)]);
        btn.Layout.Row = 1;
        btn.Layout.Column = i;
        btn.ButtonPushedFcn = @(btn,event) selectFile(i);

        fileNameLabels(i) = uilabel(gl, 'Text', '','FontSize',8, 'WordWrap','on'); 
        fileNameLabels(i).Layout.Row = 2;
        fileNameLabels(i).Layout.Column = i;
    end

    % Create a button for drawing the overlap
    drawBtn = uibutton(gl, 'Text', 'Draw Overlap');
    drawBtn.Layout.Row = 1;
    drawBtn.Layout.Column = 4;
    drawBtn.ButtonPushedFcn = @(btn,event) drawOverlap();

    % Create axes for drawing the venn diagram
    ax = uiaxes(gl);
    ax.Layout.Row = [3 6];
    ax.Layout.Column = [1 3];

    % Remove the axis, ticks, labels, and match the color to figure
    formatAxes(ax, fig);

    % Create a table for displaying the overlapping genes
    tbl = uitable(gl);
    tbl.Layout.Row = [3 6];
    tbl.Layout.Column = 4;

    % Initialize persistent variable to store the last directory
    persistent lastDir
    if isempty(lastDir)
        lastDir = pwd; % Set it to current directory initially
    end

    % Nested function for selecting a file
    function selectFile(index)
        [file, path] = uigetfile('*.txt', sprintf('Select File %d', index), lastDir);
        if file ~= 0 % if user does not press 'Cancel'
            lastDir = path; % Update the last used directory
            filePaths(index) = fullfile(path, file);
            fileNameLabels(index).Text = filePaths(index);
            % Draw the individual circle for this file
            drawSingleCircle(index);
        end
        % Bring the main GUI window back to the front using the stored handle
        figure(mainGuiHandle); % Make the main GUI figure current
        drawnow; % Update figure window
    end

    % Function to draw a single circle for a given file index
    function drawSingleCircle(index)
        % Similar logic as provided for drawing a single circle,
        % but considering the third file and adjusting the offsets and colors
        % ... [Implement draw logic for individual circles here] ...
    end

    % Function to draw overlap between three circles/files
    function drawOverlap()
        % Clear previous plots
        cla(ax);

        % Check if all files are selected
        if any(filePaths == "")
            uialert(fig, 'Please select all three files first.', 'Error');
            return;
        end

        % Logic to draw overlap between three circles
        % This includes reading the genes from each file,
        % calculating the intersections and differences,
        % and then drawing the circles with appropriate overlaps and colors.
        % ... [Implement overlap drawing logic here] ...

        formatAxes(ax, fig); % Reformat axes after drawing
    end

    % Function to format axes
    function formatAxes(ax, fig)
        ax.XAxis.Visible = 'off';
        ax.YAxis.Visible = 'off';
        ax.Color = fig.Color;
        ax.Box = 'off';
        axis(ax, 'equal');
    end

    % ... [Include any other necessary nested functions or modifications] ...
end
