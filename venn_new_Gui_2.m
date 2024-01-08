function venn_new_Gui_2(~, ~, f)
% By Berezin Lab
global circleSeparation
   
% Creating the figure at the beginning of your GUI code
fig = uifigure('Name', 'IVCCA: Venn Diagram','Position', [100 100 500 300], 'Icon','Corr_icon.png');
fig.WindowStyle = 'normal';
% Store the figure handle somewhere accessible by the selectFile function
mainGuiHandle = fig;


    % Create a grid layout
    gl = uigridlayout(fig, [4 3], 'ColumnWidth', {'1x', '1x', '1x'}, 'RowHeight', {'1x', '1x', '1x', '1x'});
    
    % Create properties for storing file paths
    filePaths = strings(2,1);

    % Create a button for selecting the first file
    btn1 = uibutton(gl, 'Text', 'Select File 1');
    btn1.Layout.Row = 1;
    btn1.Layout.Column = 1;
    btn1.ButtonPushedFcn = @(btn,event) selectFile(1);

    % Create a label for displaying the selected file name
    fileNameLabels(1) = uilabel(gl, 'Text', '','FontSize',8, 'WordWrap','on'); 
    fileNameLabels(1).Layout.Row = 2;
    fileNameLabels(1).Layout.Column = 1;

    % Create a button for selecting the second file
    btn2 = uibutton(gl, 'Text', 'Select File 2');
    btn2.Layout.Row = 1;
    btn2.Layout.Column = 2;
    btn2.ButtonPushedFcn = @(btn,event) selectFile(2);
    
    % Create a label for displaying the selected file name
    fileNameLabels(2) = uilabel(gl, 'Text', '', 'FontSize',8, 'WordWrap','on');
    fileNameLabels(2).Layout.Row = 2;
    fileNameLabels(2).Layout.Column = 2;
    
    % Create a button for drawing the overlap
    btn3 = uibutton(gl, 'Text', 'Draw Overlap');
    btn3.Layout.Row = 1;
    btn3.Layout.Column = 3;
    btn3.ButtonPushedFcn = @(btn,event) drawOverlap();

   % Create a label for displaying the results
fileNameLabels(3) = uilabel(gl, 'Text', '', 'FontSize',8, 'WordWrap','on');
fileNameLabels(3).Layout.Row = 2;
fileNameLabels(3).Layout.Column = 3;
  

% Create axes for drawing the venn diagram
ax = uiaxes(gl);
ax.Layout.Row = [3 6];
ax.Layout.Column = [1 2];

% Remove the axis, ticks, labels, and match the color to figure
ax.XAxis.Visible = 'off'; % Turn off x-axis
ax.YAxis.Visible = 'off'; % Turn off y-axis
ax.Color = fig.Color; % Match the color to the figure background
ax.Box = 'off'; % Turn off the box surrounding the axes





    % Create a table for displaying the overlapping genes
    tbl = uitable(gl);
    tbl.Layout.Row = [3 6];
    tbl.Layout.Column = 3;


    % Initialize persistent variable to store the last directory
    persistent lastDir
    if isempty(lastDir)
        lastDir = pwd; % Set it to current directory initially
    end

    % Nested function for selecting a file
function selectFile(index)
    % Store the current figure handle
    currentFig = gcf;
    
    [file, path] = uigetfile('*.txt', sprintf('Select File %d', index), lastDir);
    
    if file ~= 0 % if user does not press 'Cancel'
        lastDir = path; % Update the last used directory
        filePaths(index) = fullfile(path, file);
        fileNameLabels(index).Text = [ filePaths(index)];

        % Draw the individual circle for this file
        drawSingleCircle(index);
    end
    
    % Bring the main GUI window back to the front using the stored handle
    figure(mainGuiHandle); % Make the main GUI figure current
    drawnow; % Update figure window
end

    function drawSingleCircle(index)
    % Validate if the file exists
    if filePaths(index) == ""
        return; % Exit if no file is selected for the index
    end
    % Ensure the axes properties are maintained
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    ax.Color = fig.Color;
    ax.Box = 'off';
    % Open the file and read the genes
    fileID = fopen(filePaths(index), 'r');
    genes = textscan(fileID, '%s', 'Delimiter', ',');
    fclose(fileID);

    % Calculate the number of genes and the radius
    num_genes = length(genes{1});
    radius = sqrt(num_genes);

    % Calculate circle positions
    theta = 0:0.01:2*pi;
    x = radius * cos(theta);
    y = radius * sin(theta);

    % Adjust circle position based on index
    circleSeparation = 2.5 * max(radius); % Adjust as needed for separation
    xOffset = (index - 1) * circleSeparation; % Shift x based on index

    % Decide circle color based on index
    if index == 1
        circleColor = 'r'; % First circle is red
    else
        circleColor = 'b'; % Second circle is blue
    end

    % Draw the circle
    fill(ax, x + xOffset, y, circleColor, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    hold(ax, 'on'); % Hold on for multiple circles

    axis(ax, 'equal'); % Keep aspect ratio equal
xlim(ax, [-circleSeparation, 2*circleSeparation]); % Adjust based on circleSeparation
ylim(ax, [-1.5*radius, 1.5*radius]); % Adjust based on radius

end


    % Rest of your drawOverlap() function here, updating the axes and table
   
   function drawOverlap()
 % Clear previous plots
    cla(ax);
    if any(filePaths == "")
        uialert(fig, 'Please select both files first.', 'Error');
        return;
    end

    % Open the files
    fileID1 = fopen(filePaths(1), 'r');
    fileID2 = fopen(filePaths(2), 'r');

    % Check if the files were opened successfully
    if fileID1 == -1
        uialert(fig, ['Error opening file ', filePaths(1)], 'Error');
        return;
    end
    if fileID2 == -1
        uialert(fig, ['Error opening file ', filePaths(2)], 'Error');
        return;
    end

    % Read the data from the file
    genes1 = textscan(fileID1, '%s', 'Delimiter', ',');
    genes2 = textscan(fileID2, '%s', 'Delimiter', ',');

    % Close the file
    fclose(fileID1);
    fclose(fileID2);

    % Get the number of genes
    num_genes1 = length(genes1{1});
    num_genes2 = length(genes2{1});


    % Calculate the overlap
    overlap_genes = intersect(lower(genes1{1}), lower(genes2{1}));
    num_overlap = length(overlap_genes);

    % Check if one set is a subset of another
    subset1 = isequal(sort(lower(genes1{1})), sort(lower(overlap_genes)));
    subset2 = isequal(sort(lower(genes2{1})), sort(lower(overlap_genes)));

    % Calculate radius based on the number of genes
    radius1 = sqrt(num_genes1);
    radius2 = sqrt(num_genes2);

    % Calculate the larger radius and assign it to radius_max
   radius_max = max(radius1, radius2);

    % Initialize overlap offset
    overlapOffset = radius1 + radius2 - sqrt(num_overlap);

    % Adjust for complete overlap if sets are identical
    if isequal(sort(lower(genes1{1})), sort(lower(genes2{1})))
        radius2 = radius1; % Make radius the same for complete overlap
        overlapOffset = 0; % No offset needed as they completely overlap
    % Adjust if one set is completely inside another
    elseif subset1 || subset2
        if subset1
            % If set1 is a subset of set2, draw set1 inside set2
            overlapOffset = radius2 - 0.9 * radius1; % Set1 inside Set2
        else
            % If set2 is a subset of set1, draw set2 inside set1
            overlapOffset = radius1 - 0.9 * radius2; % Set2 inside Set1
        end
    end

    theta = 0:0.01:2*pi;

    % Calculate circle positions
    x1 = radius1 * cos(theta);
    y1 = radius1 * sin(theta);
    x2 = radius2 * cos(theta) + overlapOffset;
    y2 = radius2 * sin(theta);



    % Plot the circles in the axes
    plot(ax, x1, y1, 'r');
    hold(ax, 'on');

    c1 = fill(ax, x1, y1, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
    c2 = fill(ax, x2, y2, 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 

%     axis(ax, 'equal');
%     grid(ax, 'on'); 

    % Turn off axis and grid
axis(ax, 'off');
grid(ax, 'on');

    plot(ax, x2, y2, 'b');

    % Set the new text
    overlapText = ['Overlap between ', num2str(num_genes1), ' genes and ', num2str(num_genes2), ' genes | Overlapped genes: ', num2str(num_overlap)];

    % Assign text to the label and the title
    fileNameLabels(3).Text = overlapText;
    ax.Title.String = overlapText;
    ax.Title.Interpreter = 'none'; 
    ax.Title.FontSize = 8;

    hold(ax, 'off');
    
    legend([c1, c2], {['File 1: ' num2str(num_genes1) ' genes'], ['File 2: ' num2str(num_genes2) ' genes']}, 'Location', 'northeast')

    grid(ax, 'on');
    axis(ax, 'off');
    
    % Update the table data
    tbl.Data = cell2table(overlap_genes);
    tbl.ColumnName = {'Overlapping Genes'};

    axis(ax, 'equal'); % Keep aspect ratio equal
 xlim(ax, [-circleSeparation, 2*circleSeparation]); % Adjust based on circleSeparation
 ylim(ax, [-1.1*radius_max, 1.1*radius_max]); % Adjust based on radius


end

end
