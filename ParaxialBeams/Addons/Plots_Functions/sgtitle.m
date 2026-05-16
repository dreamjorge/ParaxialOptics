function varargout = sgtitle(varargin)
    % sgtitle - Compatibility wrapper for GNU Octave
    % MATLAB's sgtitle function adds a title above a tiled chart layout.
    % This wrapper emulates the behavior using suptitle or manual placement.
    
    % Get the title string
    titleText = varargin{1};
    
    % Try to get the current figure
    hFig = get(0, 'CurrentFigure');
    if isempty(hFig)
        % No figure, just return
        return;
    end
    
    % Try suptitle if available
    if exist('suptitle', 'file') == 2
        try
            varargout{1} = suptitle(titleText);
            return;
        end
    end
    
    % Try to add as annotation to figure
    try
        annotation(hFig, 'textbox', [0.3, 0.95, 0.4, 0.03], ...
                    'String', titleText, ...
                    'FontSize', 14, ...
                    'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center', ...
                    'LineStyle', 'none', ...
                    'FitBoxToText', 'off');
        varargout{1} = [];
    catch
        % Fallback: do nothing
        varargout{1} = [];
    end
end