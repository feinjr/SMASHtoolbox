% view View LineSegments object graphically
%
% This method displays LineSegments objects in a plot for visualization.
%     >> view(object);
% By default, a new figure is created for this plot.  Passing an axes
% handle ("target"):
%     >> view(object,target);
% plots object in an existing axes.
%
% See also LineSegments
%

%
% created October 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function view(object,target)

% manage input
if (nargin<2) || isempty(target)
    figure;
    target=gca;
end
assert(ishandle(target),'ERROR: invalid target handle');
try
    axes(target);
catch
    error('ERROR: invalid target axes requested');
end

% generate plot
switch object.NumberDimensions
    case 1
        
    case 2
        x=object.Points(:,1);
        y=object.Points(:,2);
        if strcmpi(object.BoundaryType,'wrapped')
            x(end+1)=x(1);
            y(end+1)=y(1);
        end
        h=line(x,y);
        apply(object.GraphicOptions,h);
    case 3
        
    otherwise
        
end

end