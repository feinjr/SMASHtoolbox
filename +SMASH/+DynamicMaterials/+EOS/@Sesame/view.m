% VIEW View Sesame object graphically
%
% This method displays Sesame objects as line plots, which are drawn in a
% new figure by default.
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
% By default, a plot in the Pressure-Density plane is returned is returned.
% If the object is a table, isotherms for each temperature are produced.
%   >> [...]=view(object,target,'PD');
% Objects can also be viewed in the Temperature-Pressure plane by
% specifying 'TP'. For sesame objects isochors at each density are
% produced.
%   >> [...]=view(object,target,'TP');
%
% See also Sesame
%
% created December 18, 2014 by Justin Brown (Sandia National Laboratories)
%
function varargout=view(object,target,plottype)

% handle input
new=false; table=0;
if (nargin<2) || isempty(target);
    target=figure;   
    new=true;
elseif ~ishandle(target)
    error('ERROR: invalid target handle');
end

if (nargin < 3)
    plottype = 'PD';
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


if strcmpi(object.SourceFormat,'sesame')
    table=1;
end


% View in Pressure-Density plane
if strcmpi(plottype,'PD')
    if table
        rho = unique(object.Density);
        temp = unique(object.Temperature);
        for i = 1:length(temp)
            tempobj = isotherm(object,rho,temp(i));
                x = tempobj.Density;
                y = tempobj.Pressure;

                minpressure = max(min(object.Pressure),1e-3);
                bad = y <= minpressure;
                y(bad) = minpressure;

            %h=line(log10(x),log10(y));
            set(target,'xscale','log','yscale','log');
            h=line(x,y);
            apply(object.GraphicOptions,h);
            axis tight;
        end
    else
        h=line(object.Density,object.Pressure);
        apply(object.GraphicOptions,h);
    end
    xlabel([object.XLabel]);
    ylabel([object.ZLabel]);
end

% View in Temperature-Pressure plane
if strcmpi(plottype,'TP')
    if table
        rho = unique(object.Density);
        temp = unique(object.Temperature);

        for i = 1:length(rho)
            tempobj = isochor(object,temp,rho(i));
                x = tempobj.Pressure;
                y = tempobj.Temperature;

                minpressure = max(min(object.Pressure),1e-3);
                bad = x <= minpressure;
                x(bad) = minpressure;

            set(target,'xscale','log','yscale','log');
            h=line(x,y);
            apply(object.GraphicOptions,h);
            axis tight;
        end
    else
        h=line(object.Pressure,object.Temperature);
        apply(object.GraphicOptions,h);
    end
    xlabel([object.ZLabel]);
    ylabel([object.YLabel]);
end

% View in 3D
if strcmpi(plottype,'3D')
    if table
        rho = unique(object.Density);
        temp = unique(object.Temperature);

        for i = 1:length(temp)
            tempobj = isotherm(object,rho,temp(i));
                x = tempobj.Temperature;
                y = tempobj.Density;
                z = tempobj.Pressure;
                
                minpressure = max(min(object.Pressure),1e-3);
                bad = x <= minpressure;
                x(bad) = minpressure;

            set(target,'xscale','log','yscale','log');
            h=line(x,y,z);
            apply(object.GraphicOptions,h);
            axis tight;
        end
    else
        h=line(object.Pressure,object.Temperature);
        apply(object.GraphicOptions,h);
    end
    xlabel([object.ZLabel]);
    ylabel([object.YLabel]);
end



title(target,object.Title);
box(target,'on');
figure(fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end