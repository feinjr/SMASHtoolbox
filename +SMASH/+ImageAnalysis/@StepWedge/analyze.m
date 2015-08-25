function varargout=analyze(object)

% initial preparations
%object=crop(object,'manual');
object=rotate(object,'auto');

% generate exposure table
N=numel(object.StepOffsets);
OD=sort(object.StepLevels);
OD=OD(end:-1:1);

OD=repmat(OD,[N 1]);
offset=sort(object.StepOffsets);
offset=offset(end:-1:1);
layer=zeros(size(OD));
for n=1:N
    OD(n,:)=OD(n,:)+offset(n);
    layer(n,:)=n;
end

exposure=10.^(-OD);
exposure=exposure/median(exposure(:)); % normalize by median
exposure=exposure(:);
Nexposure=numel(exposure);

% calculate levels and associate with exposure
level=zeros(Nexposure,1);
for k=1:size(object.RegionTable,1)
    x1=object.RegionTable(k,1);
    x2=x1+object.RegionTable(k,3);
    y1=object.RegionTable(k,2);
    y2=y1+object.RegionTable(k,4);
    n=(object.Measurement.Grid1>=x1) & (object.Measurement.Grid1<=x2);
    m=(object.Measurement.Grid2>=y1) & (object.Measurement.Grid2<=y2);
    temp=object.Measurement.Data(m,n);
    level(k)=median(temp(:));    
%     temp=sort(temp(:));
%     start=round(0.25*numel(temp));
%     stop=round(0.75*numel(temp));
%     temp=temp(start:stop);
%     level(k)=mean(temp);
%     Dlevel(k)=std(temp);
end
[level,index]=sort(level);
exposure=exposure(index);
layer=layer(index);

% create transfer curve
x=log10(exposure);
y=level;
y1=min(y)+object.CalibrationRange(1)*range(y);
y2=min(y)+object.CalibrationRange(2)*range(y);
keep=(y>=y1)&(y<=y2);
p=polyfit(x(keep),y(keep),6);
xs=linspace(min(x(keep)),max(x(keep)),100);
ys=polyval(p,xs);

object.TransferTable=[ys(:) 10.^(xs(:))];

% handle output
SMASH.MUI.Figure;
ha(1)=subplot(3,1,1);
imagesc(object.Measurement.Grid1,object.Measurement.Grid2,object.Measurement.Data);
colormap(object.Measurement.GraphicOptions.ColorMap);
xlabel(object.Measurement.Grid1Label);
ylabel(object.Measurement.Grid2Label);
temp=sprintf('Wedge regions for ''%s''',object.Measurement.GraphicOptions.Title);
title(temp);
for n=1:size(object.RegionTable,1)
    rectangle('Position',object.RegionTable(n,:),'EdgeColor','k','LineStyle','-');
    rectangle('Position',object.RegionTable(n,:),'EdgeColor','w','LineStyle','--');
end

ha(2)=subplot(3,1,2);
box on;
marker={'o' 'x'};
for k=1:2
    keep=(layer==k);
    line(exposure(keep),level(keep),...
        'LineStyle','none','Color','k','Marker',marker{k});
end
line(object.TransferTable(:,2),object.TransferTable(:,1));
xlabel('Relative exposure');

ylabel('Density');
set(gca,'XScale','log');

ha(3)=subplot(3,1,3); %#ok<NASGU>
plot(object.TransferTable(:,1),object.TransferTable(:,2),'k');
xlabel('Density');
ylabel('Relative exposure');
set(gca,'YScale','log');

if nargout>=1
    varargout{1}=object;
end

end

function result=range(array)

result=max(array(:))-min(array(:));

end