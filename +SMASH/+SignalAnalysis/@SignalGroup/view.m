% VIEW View SignalGroup object graphically
%
% This method displays SignalGroup objects as line plots, which are drawn
% in a new figure by default.
%    >> view(object); 
%    >> h=view(object); % return line's graphic handle
% The line's properties (color, width, etc.), axes labels, and title  are
% defined by the object.
%
% To display the signal in an existing figure, pass a graphic handle as a
% second input.
%    >> [...]=view(object,target);
% Passing a valid axes handle draws signals without overwriting labels.  If
% "target" is an empty variable, a new axes is created in a new figure
% (just as if no argument was passed).  Passing a figure handle causes the
% Signal to be drawn in the current axes and overwrites the labels; if no
% axes is present, a new one is created.
%
% Passing an index array limits the plot to specific signals from the
% group.
%    >> view(object,target,1); % display first signal only
%    >> view(object,target,[2 3]); % display second and third signals
%
% See also Signal
%

%
% created November 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function varargout=view(object,index,target)

% handle input
if (nargin<2) || isempty(index) || strcmpi(index,'all');
    index=1:object.NumberSignals;
end

new=false;
if (nargin<3) || isempty(target);
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

% create line with object's properties
[time,value]=limit(object);
h=nan(object.NumberSignals,1);
color=lines(object.NumberSignals);
for n=index
    h(n)=line(time,value(:,n));
    set(h(n),'Color',color(n,:));
end
h=h(~isnan(h));

% fill out new figure
if new
    xlabel(target,object.GridLabel);
    ylabel(target,object.DataLabel);
    if ~isempty(object.Legend)
        legend(object.Legend(index),'Location','best');       
    end
    box on;
end

figure(fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end