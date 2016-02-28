% view Display measurements
%
% This method ...

%
%
%
function varargout=view(object,target)

% manage input
if (nargin<2) || isempty(target)
    figure;
    NewFigure=true;
    target=axes('Box','on');
    xlabel(object.XLabel);
    ylabel(object.YLabel);
else
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');
    NewFigure=false;
end

% plot original boundary curve
N=object.NumberMeasurements;
hbound=nan(1,N);
hmode=nan(1,N);
for n=1:N
    temp=object.ProbabilityDensity{n}.Original.Boundary;
    hbound(n)=line('Parent',target,...
        'XData',temp(:,1),'YData',temp(:,2));
    apply(object.GraphicOptions,hbound(n),'noparent');
    set(hbound(n),'Marker','none');
    temp=object.ProbabilityDensity{n}.Original.Mode;
    hmode(n)=line('Parent',target,...
        'XData',temp(1),'YData',temp(2));
    apply(object.GraphicOptions,hmode(n),'noparent');
end

if NewFigure
    axis(target,'auto');
end

% manage output
if nargout>0
    varargout{1}=hbound;
    varargout{2}=hmode;
end

end