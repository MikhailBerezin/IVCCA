% Update figure icon
function hFig_ = setIcon(hFig, iconFilename)
    if nargin < 1,  hFig = gcf;  end

    folder = fileparts(mfilename('fullpath'));  %=pwd
    if nargin < 2,  iconFilename = fullfile(folder,'Images','idcube-icon-transparent.png');  end

    % Load the icon - this will croak if image is not available/readable
    jIcon = javax.swing.ImageIcon(iconFilename);

    % Set the figure icon
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    try jf = hFig.JavaFrame_I; catch, jf = hFig.JavaFrame; end %#ok<JAVFM>
    try jf.setFigureIcon(jIcon); catch, end
    warning on MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame

    if nargout
        hFig_ = hFig;
    end
end
