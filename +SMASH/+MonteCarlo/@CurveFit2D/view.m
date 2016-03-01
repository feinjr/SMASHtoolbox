% view Display measurements
%
% This method ...

%
%
%
function varargout=view(object)

figure;
target=axes('Box','on');
xlabel(object.XLabel);
ylabel(object.YLabel)

% plot measurement boundaries
N=object.NumberMeasurements;
assert(N>0,'ERROR: no measurements added yet');
hbound=nan(1,N);
hcenter=nan(1,N);
for n=1:N
    temp=object.MeasurementDensity{n}.Original.Boundary;
    hbound(n)=line('Parent',target,...
        'XData',temp(:,1),'YData',temp(:,2));
    set(hbound(n),'Marker','none','Color','r');
    temp=object.MeasurementDensity{n}.Original.Mode;
    hcenter(n)=line('Parent',target,...
        'XData',temp(1),'YData',temp(2));
    set(hcenter(n),'Marker','+','Color','r');
end

% plot model
if ~isempty(object.Model)
    temp=object.CurvePoints;
    hmodel=line('Parent',target,...
        'XData',temp(:,1),'YData',temp(:,2));
    set(hmodel,'Marker','none','Color','k');
end


axis(target,'auto');

% manage output
if nargout>0
    varargout{1}=hbound;
    varargout{2}=hcenter;
    varargout{3}=hmodel;
end

end