% VIEW View Radiation object graphically
%
% This method displays Radiation objects as line (or signal) plots, 
% which are drawn in a new figure by default.
%    >> view(object,group,index,target); 
%    >> h=view(object); % return line's graphic handle
% The line's properties (color, width, etc.), axes labels, and title are
% defined by the object.
%
% Passing an group value ('time' or 'wavelength') to specify which signals 
% to plot
%    >> view(object,'time'); % displays group of signals at various time 
%                              points
%    >> view(object,'wavelength'); % displays group of signals at various 
%                                    wavelength points
%
% Passing an index array limits the plot to specific points
%    >> view(object,'wavelength',1); % displays only the signal at the 
%                                      first wavelength point
%    >> view(object,,'time',[4 10]); % display fourth and tenth signals at 
%                                      the fourth & tenth time points
%    >> view(object,'time','all'); % displays signals at all time points
%
% To display the object in an existing figure, pass a graphic handle as a
% fourth input.
%    >> [...]=view(object,'time','all',target);
% Passing a valid axes handle draws signals without overwriting labels.  If
% "target" is an empty variable, a new axes is created in a new figure
% (just as if no argument was passed).  Passing a figure handle causes the
% object to be drawn in the current axes and overwrites the labels; if no
% axes is present, a new one is created.
%
% See also Radiation
%

% created March 27, 2014 by Tommy Ao (Sandia National Laboratories) 
%
function varargout=view(object,group,index,target)

% handle inputs
% group to plot
if (nargin<2) || isempty(group)
    group='time'; % default time group
    index=1:object.NumberTimes;
end
switch group
        case {'time','wavelength'}
            % do nothing
    otherwise
        error('ERROR: Invalid group value, must be time or wavelength');
end

% index of signals to plot
if (nargin<3) || isempty(index) || strcmpi(index,'all')
    switch group
        case 'time';
            index=1:object.NumberTimes;
        case 'wavelength';
            index=1:object.NumberWavelengths;
    end
end
% too many signals to plot
if length(index)>20
    error('ERROR: Too many signals to plot (<20)')
end

% new or existing figure target
new=false;
if (nargin<4) || isempty(target);
    target=figure;   
    new=true;
elseif ~ishandle(target)
    error('ERROR: invalid target handle');
end
% verify target axes
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

% limit plot
[wavelength,time,value]=limit(object);
switch group
    case 'time'
        % create signals at specific times
        object.LineColor=lines(object.NumberTimes);
        object.Legend=cell(1,object.NumberTimes);
        h=nan(object.NumberTimes,1);
        for n=index
            h(n)=line(wavelength,value(:,n));
            set(h(n),'Color',object.LineColor(n,:),'LineStyle',object.LineStyle,...
                'LineWidth',object.LineWidth,'Marker',object.Marker);
            object.Legend{n}=sprintf('time %0.2e ns',object.Time(n));
        end
        h=h(~isnan(h));
        gridLabel=object.WavelengthLabel;
    case 'wavelength'
        % create signals at specific wavelengths
        object.LineColor=lines(object.NumberWavelengths);
        object.Legend=cell(1,object.NumberWavelengths);
        h=nan(object.NumberWavelengths,1);
        for n=index
            h(n)=line(time,value(n,:));
            set(h(n),'Color',object.LineColor(n,:),'LineStyle',object.LineStyle,...
                'LineWidth',object.LineWidth,'Marker',object.Marker);
            object.Legend{n}=sprintf('wavelength %d nm',object.Wavelength(n));
        end
        h=h(~isnan(h));
        gridLabel=object.TimeLabel;
end

% fill out new figure
if new
    xlabel(target,gridLabel);
    ylabel(target,object.DataLabel);
    title(target,object.Title);
    box(target,'on');
    legend(object.Legend(index),'Location','best');
end

figure(fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end