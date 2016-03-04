% view Display measurements
%
% This method ...

%
%
%
function varargout=view(object)

% manage input

% create figure

figure;
target=axes('Box','on');
xlabel(object.XLabel);
ylabel(object.YLabel)

% plot measurement boundaries
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
        if strcmpi(get(children(n),'Tag'),'densitycontour')
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