% view Display object
%
% This method generates a graphical display of Density2D object.  Density
% contours are shown as black lines.  The asterisk (*) indicates mean
% location
%    view(object); % generate plot in a new figure
%    view(object,target); % plot in an existing target axes
%    h=view(...); % return graphic handles
%
% See also Density2D
%

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
function varargout=view(object,target)

% manage input
assert(~isempty(object.Original),...
    'ERROR: density has not been calculated yet');

if (nargin<2) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
    'ERROR: invalid target axes');

% plot contours and important points
h=hggroup('Tag','Density2D plot');

hc=SMASH.Graphics.plotContourMatrix(object.Original.ContourMatrix,target);
set(hc,'Parent',h,'Color','k','LineStyle','--','Tag','DensityContour');

%hmode=line(object.Original.Mode(1),object.Original.Mode(2),...
%    'Color','k','Marker','+','Tag','Mode');
%set(hmode,'Parent',h);

hmean=line(object.Original.Mean(1),object.Original.Mean(2),...
    'Color','k','Marker','*','Tag','Mean');
set(hmean,'Parent',h);

% manage output
if nargout>0
    varargout{1}=h;
end

end