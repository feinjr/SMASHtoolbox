% view Display curve
%
% This method displays the measurements and model curve for a CurveFit2D
% object.
%    view(object);
%    [hmeasure,hmodel]=view(object); % return graphic handles
% Calling this method generates a new figure with density contours for each
% measurement and a line for the model curve.
%
% A limited set of graphic options are used by this method:
%    MeasurementColor
%    MeasurementStyle
%    ModelColor
%    ModelStyle
%    ModelWidth
% Setting these options (in the GraphicOptions property) affects all
% subsequent calls to the view method.
%
% See also CurveFit2D, summarize
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,target)

% manage input
if (nargin<2) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target) && strcmpi(get(target,'type'),'axes'),...
    'ERROR: invalid target axes');
xlabel(object.XLabel);
ylabel(object.YLabel)

% plot measurement contours
N=object.NumberMeasurements;
assert(N>0,'ERROR: no measurements added yet');
hmeasure=nan(1,N);
for n=1:N
    hmeasure(n)=view(object.MeasurementDensity{n},target);    
    setappdata(hmeasure(n),'Measurement',n);
    children=get(hmeasure(n),'Children');
    for m=1:numel(children)
         set(children(m),...
            'Color',object.GraphicOptions.MeasurementColor);
        if strcmpi(get(children(m),'Tag'),'densitycontour')
            set(children(m),...
                'LineStyle',object.GraphicOptions.MeasurementStyle);
        end
        setappdata(children(m),'Measurement',n);        
    end
end

% plot model
hmodel=[];
if ~isempty(object.Model)
    temp=object.CurvePoints;
    hmodel=line('Parent',target,'Tag','Model',...
        'XData',temp(:,1),'YData',temp(:,2));
    set(hmodel,'Marker','none',...
        'Color',object.GraphicOptions.ModelColor,...
        'LineStyle',object.GraphicOptions.ModelStyle,...
        'LineWidth',object.GraphicOptions.ModelWidth);
end

axis(target,'tight');

% manage output
if nargout>0
    varargout{1}=hmeasure;
    varargout{2}=hmodel;
end

end