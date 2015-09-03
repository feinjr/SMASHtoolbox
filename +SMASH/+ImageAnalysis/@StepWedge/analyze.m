% analyze Analyze step wedge
%
% This method analyzes the step wedge image to determine how
% measured optical density maps to film exposure.  
%     >> object=analyze(object);
% Analysis must be performed before the apply method can be used.
%
% Step wedge analysis several intermediate steps.
%   -The user is prompted to crop the measurement (if not already done).
%   -Automatic rotation is applied to orient the measurement.
%   -Constant regions are identified by transitions of peak slope.
%   -Median values from each constant region are associated with total
%   optical density (step value plus offset)
% Analysis is controlled by various settings (derivative parameters, etc.).
%  These settings may be adjusted using the "configure" method.
%
% See also StepWedge, apply, configure, clean, crop, rotate
%

%
% created August 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyze(object)

% initial preparations
if ~object.Cropped
    object=crop(object,'manual');
end
object=rotate(object,'auto');
object=locate(object);

% generate exposure table
N=numel(object.Settings.StepOffsets);
OD=sort(object.Settings.StepLevels);
OD=OD(end:-1:1);

OD=repmat(OD,[N 1]);
offset=sort(object.Settings.StepOffsets);
offset=offset(end:-1:1);
layer=zeros(size(OD));
for n=1:numel(offset)
    OD(n,:)=OD(n,:)+offset(n);
    layer(n,:)=n;
end

exposure=10.^(-OD);
exposure=exposure/median(exposure(:)); % normalize by median
exposure=exposure(:);
Nexposure=numel(exposure);

% calculate levels and associate with exposure
level=zeros(Nexposure,1);
for k=1:size(object.Results.RegionTable,1)
    x1=object.Results.RegionTable(k,1);
    x2=x1+object.Results.RegionTable(k,3);
    y1=object.Results.RegionTable(k,2);
    y2=y1+object.Results.RegionTable(k,4);
    n=(object.Measurement.Grid1>=x1) & (object.Measurement.Grid1<=x2);
    m=(object.Measurement.Grid2>=y1) & (object.Measurement.Grid2<=y2);
    temp=object.Measurement.Data(m,n);
    level(k)=median(temp(:));    
end
[level,index]=sort(level);
%exposure=exposure(index);
layer=layer(index);

% create transfer curve
%x=log10(exposure);
x=-OD(index);
x=x-median(x);
y=level;
object.Results.TransferPoints=[x(:) y(:) layer(:)];
%fitStep(x,y);
%keyboard

min_y=min(y);
max_y=max(y);
Ly=max_y-min_y;
y1=min_y+object.Settings.AnalysisRange(1)*Ly;
y2=min_y+object.Settings.AnalysisRange(2)*Ly;

keep=(y>=y1)&(y<=y2);
p=polyfit(x(keep),y(keep),object.Settings.PolynomialOrder);
xs=linspace(min(x(keep)),max(x(keep)),1000);
ys=polyval(p,xs);

pd=polyder(p);
slope=polyval(pd,xs(end));
y0=mean(y(y>y2));
x0=xs(end)-(ys(end)-y0)/slope; % project curve to upper bound
xs(end+1)=x0;
ys(end+1)=y0;

slope=polyval(polyder(p),xs(1));
y0=mean(y(y<y1));
x0=xs(1)-(ys(1)-y0)/slope; % project curve to lower bound
xs(end+1)=x0;
ys(end+1)=y0;

[xs,index]=sort(xs);
ys=ys(index);

xsn=linspace(min(xs),max(xs),1000);
ys=interp1(xs,ys,xsn);
xs=xsn;
object.Results.TransferTable=[ys(:) 10.^(xs(:))];

object.Analyzed=true;
view(object,'Results');

% handle output
if nargout==0
    % do nothing
else    
    object.Analyzed=true;
    varargout{1}=object;    
end

end