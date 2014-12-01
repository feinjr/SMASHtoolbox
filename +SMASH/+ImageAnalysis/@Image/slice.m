% SLICE  Generate Image slices (lineouts)
%
% This function slices an Image object at specified grid locations.
%    >> result=slice(object,coordinate,value);
% The input "coordinate"  should be 'Grid1' or 'Grid2'; "value" can be one
% or more grid locations within that grid.  If these inputs are omitted,
% the user will be prompted to select them.  The output of this method is a
% SignalGroup object; slices are plotted in a new figure when no output is
% specified.
%
% See also Image, mean, SignalAnalysis.SignalGroup
%

%
% created November 25, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=slice(object,coordinate,value)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Choose slice coordinate','Slice coordinate',...
        ' Grid1 ',' Grid2 ',' cancel ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if strcmp(coordinate,'cancel')
        return
    end
elseif ~strcmpi(coordinate,'Grid2') && ~strcmpi(coordinate,'Grid1')
    error('ERROR: %s is an invalid coordinate',coordinate);
end

if (nargin<3) || isempty(value) % prompt user to select slices
    value=SelectValue(coordinate,object);       
end   

% calculate slices
label=cell(1,numel(value));
[x,y,z]=limit(object);
switch lower(coordinate)
    case 'grid1'
        Grid=y;
        Data=nan(numel(y),numel(value));
        for k=1:numel(value)
            Data(:,k)=interp2(object.Grid1,object.Grid2,object.Data,...
                value(k),Grid);
            label{k}=sprintf('%s=%g',coordinate,value(k));
        end               
        result=SMASH.SignalAnalysis.SignalGroup(y,Data);
        result.GridLabel=object.Grid2Label;
    case 'grid2'
        Grid=x;
        Data=zeros(numel(value),numel(x));
        for k=1:numel(value)
            Data(k,:)=interp2(object.Grid1,object.Grid2,object.Data,...
                Grid,value(k));
            label{k}=sprintf('%s=%g',coordinate,value(k));
        end
        result=SMASH.SignalAnalysis.SignalGroup(x,transpose(Data));
        result.GridLabel=object.Grid1Label;
end
result.DataLabel=object.DataLabel;
result.Title=sprintf('%s slice of "%s"',coordinate,object.Name);
result.Legend=label;

% handle output
if nargout==0
    view(result);
end

if nargout==1
    varargout{1}=result;
end

if nargout==2 % this mode is undocumented
    varargout{1}=coordinate;
    varargout{2}=z;
end

end

%% 
function value=SelectValue(coordinate,object)

% create selection interface
h=view(object,'show');
title(h.axes,'Choose slice: ');
switch lower(coordinate)
    case 'grid1'
        Grid2=ylim(h.axes);
        Grid1=nan(size(Grid2));
    case 'grid2'
        Grid1=xlim(h.axes);
        Grid2=nan(size(Grid1));         
end
hline=line('Parent',h.axes,'XData',Grid1,'YData',Grid2,...
    'Color',object.LineColor,'Tag','SliceGuide');

fig=ancestor(h.axes,'figure');
set(fig,'WindowButtonMotionFcn',@MoveSliceGuide);
set(h.image,'ButtonDownFcn',@ButtonDown);
set(hline,'ButtonDownFcn',@ButtonDown);
    function MoveSliceGuide(varargin)
        pos=get(h.axes,'CurrentPoint');
        Grid1=repmat(pos(1,1),[1 2]);
        Grid2=repmat(pos(1,2),[1 2]);
        switch lower(coordinate)
            case 'grid1'
                Grid2=ylim(h.axes);
                temp=sprintf('Choose slice: %s = %g',object.Grid1Label,Grid1(1));
            case 'grid2'               
                Grid1=xlim(h.axes);
                temp=sprintf('Choose slice: %s = %g',object.Grid2Label,Grid2(1));
        end        
        set(hline,'Xdata',Grid1,'YData',Grid2);
        title(h.axes,temp);
    end

    function ButtonDown(varargin)        
        set(hline,'Tag','SliceLine');            
    end
        
% wait for user to click on image (which changes the slice guide tag)
waitfor(hline,'Tag');
switch lower(coordinate)
    case 'grid1'
        value=get(hline,'XData');
    case 'grid2'
        value=get(hline,'YData');
end
value=value(1);

delete(fig);

end