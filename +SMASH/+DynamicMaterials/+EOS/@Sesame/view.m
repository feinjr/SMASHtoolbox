% VIEW View Sesame object graphically
%
% This method displays Sesame objects as isotherm line plots, which are 
% drawn in a new figure by default. A pressure cutoff of 1e-3 is used to
% reduce clutter in the plot. 
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
% By default, a plot Pressure vs Density isotherms is returned. It is
% possilbe to view the Temperature vs Pressure isochors by specifying:
%   >> [...]=view(object,target,'isochors');
%
% See also Sesame
%
% created December 18, 2014 by Justin Brown (Sandia National Laboratories)
%
function varargout=view(object,target,plottype)

% handle input
new=false;
if (nargin<2) || isempty(target);
    target=figure;   
    new=true;
elseif ~ishandle(target)
    error('ERROR: invalid target handle');
end

if (nargin < 3)
    plottype = 'isotherms';
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

rho = unique(object.Density);
temp = unique(object.Temperature);

% create isotherms
if strcmpi(plottype,'isotherms')

    for i = 1:length(temp)
        tempobj = isotherm(object,rho,temp(i));
            x = tempobj.Density;
            y = tempobj.Pressure;

            minpressure = max(min(object.Pressure),1e-3);
            bad = y <= minpressure;
            y(bad) = minpressure;

        h=line(log10(x),log10(y));
        apply(object.GraphicOptions,h);
    end
end

% create isochors
if strcmpi(plottype,'isochors')
    rho = unique(object.Density);
    temp = unique(object.Temperature);

    for i = 1:length(rho)
        tempobj = isochor(object,temp,rho(i));
            x = tempobj.Pressure;
            y = tempobj.Temperature;
            
            minpressure = max(min(object.Pressure),1e-3);
            bad = x <= minpressure;
            x(bad) = minpressure;
            
        h=line(log10(x),log10(y));
        apply(object.GraphicOptions,h);
    end
end

%set(h,'Color',object.LineColor,'LineStyle',object.LineStyle,...
%    'LineWidth',object.LineWidth,'Marker',object.Marker);

% fill out new figure
if new
    if strcmpi(plottype,'isochors')
        xlabel(['log ',object.ZLabel]);
        ylabel(['log ',object.YLabel]);
    else
        xlabel(['log ',object.XLabel]);
        ylabel(['log ',object.ZLabel]);
    end
    title(target,object.Title);
    box(target,'on');
end

figure(fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end