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
hmeasure=nan(1,N);
for n=1:N
    hmeasure(n)=view(object.MeasurementDensity{n},target);    
end

% plot model
hmodel=[];
if ~isempty(object.Model)
    temp=object.CurvePoints;
    hmodel=line('Parent',target,...
        'XData',temp(:,1),'YData',temp(:,2));
    set(hmodel,'Marker','none','Color','k');
end


axis(target,'auto');

% manage output
if nargout>0
    varargout{1}=hmeasure;
    varargout{2}=hmodel;
end

end