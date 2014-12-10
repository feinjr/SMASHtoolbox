% VIEW View Sesame object graphically
%
% This method displays Sesame objects as isotherm line plots, which are 
% drawn in a new figure by default.
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
% See also Signal
%

%
% created November 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function varargout=view(object,target)

% handle input
new=false;
if (nargin<2) || isempty(target);
    target=figure;   
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

% create isotherms
rho = unique(object.Density);
temp = unique(object.Temperature);

for i = 1:length(temp)
    tempobj = isotherm(object,rho,temp(i));
        x = tempobj.Density;
        y = tempobj.Pressure;
        
        minpressure = max(min(object.Pressure),1e-3);
        bad = y <= minpressure;
        y(bad) = minpressure;
        %bad2 = log(y) <= log(minpressure);
        %y(bad2) = minpressure;
        
        
    h=line(log(x),log(y));
    apply(object.GraphicOptions,h);
end


%set(h,'Color',object.LineColor,'LineStyle',object.LineStyle,...
%    'LineWidth',object.LineWidth,'Marker',object.Marker);

% fill out new figure
if new
    xlabel(['log ',object.XLabel]);
    ylabel(['log ',object.ZLabel]);
    title(target,object.Title);
    box(target,'on');
end

figure(fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end