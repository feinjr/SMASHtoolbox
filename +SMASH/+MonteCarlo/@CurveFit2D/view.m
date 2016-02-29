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

% plot original boundary curve
N=object.NumberMeasurements;
hbound=nan(1,N);
hmode=nan(1,N);
for n=1:N
    temp=object.MeasurementDensity{n}.Original.Boundary;
    hbound(n)=line('Parent',target,...
        'XData',temp(:,1),'YData',temp(:,2));
    set(hbound(n),'Marker','none','Color','r');
    temp=object.MeasurementDensity{n}.Original.Mode;
    hmode(n)=line('Parent',target,...
        'XData',temp(1),'YData',temp(2));
    set(hmode(n),'Marker','+','Color','r');
end

axis(target,'auto');

% manage output
if nargout>0
    varargout{1}=hbound;
    varargout{2}=hmode;
end

end