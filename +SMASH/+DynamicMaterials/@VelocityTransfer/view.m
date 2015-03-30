% VIEW View VelocityTransfer object graphically
%
% This method displays the velocities defined in the VelocityTransfer
% object
%    >> view(object); 
%    >> h=view(object); % return line's graphic handle
% The line's properties (color, width, etc.), axes labels, and title are
% defined by the object.
%
% To display the signal in an existing figure, pass a graphic handle as a
% second input.
%    >> [...]=view(object,target);
% If target is a valid axes handle, the Signal is drawn without altering
% the title or axes labels.  Passing a figure handle causes the Signal to
% be drawn in the current axes and overwrites the labels; if no axes is
% present, a new one is created.
%
% See also VelocityTransfer, Signal
%
% created March 26, 2015 by Justin Brown (Sandia National Laboratories) 
%
function varargout=view(object,target)

% handle input
new=false;
if (nargin<2) || isempty(target);
    %target=figure;   
    target=SMASH.MUI.Figure;
    target=target.Handle;
    set(target,'NumberTitle','on','Name','VelocityTransfer view');
    new=true;
elseif ~ishandle(target)
    error('ERROR: invalid target handle');
end

switch lower(get(target,'Type'))
    case 'axes'
        fig=ancestor(target,'figure');
    case 'figure'
        fig=target;
        target=get(fig,'CurrentAxes');
        if isempty(target)
            target=axes('Parent',fig);
        end
        new=true;
    otherwise
        error('ERROR: invalid target handle');
end
axes(target);

% create lines with object's properties
[time,value]=limit(object.MeasuredWindow);
h=line(time,value);
apply(object.MeasuredWindow.GraphicOptions,h);

[time,value]=limit(object.SimulatedWindow);
h=line(time,value);
apply(object.SimulatedWindow.GraphicOptions,h);

[time,value]=limit(object.SimulatedInsitu);
h=line(time,value);
apply(object.SimulatedInsitu.GraphicOptions,h);

%Display the result if it exists
if isobject(object.Results)
    [time,value]=limit(object.Results);
    h=line(time,value); 
    apply(object.Results.GraphicOptions,h);
end

% fill out new figure
if new
    xlabel(target,object.MeasuredWindow.GridLabel);
    ylabel(target,object.MeasuredWindow.DataLabel);
end

figure(fig);
axis tight;


% handle output
if nargout>=1
    varargout{1}=h;
end

end