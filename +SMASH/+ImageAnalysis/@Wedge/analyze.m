% ANALYZE Step wedge analysis
%
% Analyze the Wedge object to determine the transfer table of film
% exposure to linearized intensity level using a default optical density
% OD setting:   
%   >> object=analyze(object);
% or with an input exposure optical density (OD) setting:
%   >> object=analyze(object,opticalDensity); % specifiy 2 x 21 OD array
%
% To only view the analyzed Wedge tranfer table without an output:
%   >> analyze(object);
%
% See also ImageAnalysis, Wedge, apply
%

% created December 5, 2013 by Tommy Ao (Sandia National Laboratories)
% updated January 1, 2014 by Daniel Dolaln
%    -revised code to use Signal class (generated by Image.mean) instead of
%    the SmoothDerivative function
%
%%
function varargout=analyze(object,opticalDensity)

% handle input
if (nargin<2) || isempty(opticalDensity)
    OD=[0.08 0.20 0.35 0.51 0.64 0.78 0.94 ...
        1.12 1.25 1.39 1.54 1.67 1.82 1.98 ...
        2.15 2.29 2.43 2.59 2.76 2.91 3.02];
    OD=OD(end:-1:1);
    %offset=2.03; % default
    %offset=2.00;
    offset=2.13; % gives better overlap
    OD=[OD; OD+offset];  
end
exposure=10.^(-OD);
exposure=exposure/exposure(2,end); % normalize by midpoint
%exposure=transpose(exposure);
exposure=exposure(:);
Nexposure=numel(exposure);

% prompt user to crop data
object=crop(object,'manual');

% define vertical boundaries
temp=sum(object.Data,2);
temp=temp(:);
y=object.Grid2(:);
temp=(temp-min(temp))/(max(temp)-min(temp));
index=(temp>=0.05) & (temp<=0.95);
p=polyfit(y(index),temp(index),1);
midpoint=(0.5-p(2))/p(1);
width=abs(1/p(1));
positionA=midpoint-width;
positionB=midpoint+width;
if temp(1)>temp(end)
    yboundA=[y(1) positionA];
    yboundB=[positionB y(end)];
else
    yboundB=[y(1) positionA];
    yboundA=[positionB y(end)];    
end

 % define horizontal boundaries
temp=mean(object,'Grid2');
deriv=differentiate(temp,[1 9]);
x=object.Grid1;
deriv=deriv.Data;
[~,index]=max(abs(deriv));
deriv=deriv/deriv(index);
[frequency,bin]=hist(deriv,-0.10:0.01:1.00);
frequency=frequency/max(frequency);
width=find((bin>0) & (frequency<exp(-1)),1,'first');
width=bin(width);
%deriv(deriv<0.30)=nan;
deriv(deriv<5*width)=nan;
xbound=zeros(1,(Nexposure/2)-1);
for k=1:numel(xbound)
    start=find(~isnan(deriv),1,'first');
    if isempty(start)
        break
    end
    deriv=deriv(start:end);       
    x=x(start:end);    
    stop=find(isnan(deriv),1,'first');
    if isempty(stop)
        break
    end
    [~,index]=max(deriv(1:stop));
    xbound(k)=x(index);
    deriv=deriv(stop:end);
    x=x(stop:end);
end
left=[object.Grid1(1) xbound];
right=[xbound object.Grid1(end)];

ROI=[];
for k=1:numel(left)
    x0=left(k);
    Lx=abs(right(k)-left(k));
    x0=x0+0.10*Lx;
    Lx=0.80*Lx;
    y0=yboundA(1);
    Ly=range(yboundA);
    y0=y0+0.10*Ly;
    Ly=0.80*Ly;
    ROI(end+1,:)=[x0 y0 Lx Ly];
    y0=yboundB(1);
    Ly=range(yboundB);
    y0=y0+0.10*Ly;
    Ly=0.80*Ly;
    ROI(end+1,:)=[x0 y0 Lx Ly];
end

% calculate levels and associate with exposure
level=zeros(Nexposure,1);
Dlevel=level;
for k=1:size(ROI,1)
    x1=ROI(k,1);
    x2=x1+ROI(k,3);
    y1=ROI(k,2);
    y2=y1+ROI(k,4);
    n=(object.Grid1>=x1) & (object.Grid1<=x2);
    m=(object.Grid2>=y1) & (object.Grid2<=y2);
    temp=object.Data(m,n);
    temp=sort(temp(:));
    start=round(0.05*numel(temp));
    stop=round(0.95*numel(temp));
    temp=temp(start:stop);
    level(k)=mean(temp);
    Dlevel(k)=std(temp);
end
[level,index]=sort(level);
%exposure=sort(exposure(:));
exposure=exposure(index);

% create transfer curve
x=log10(exposure);
y=level;
y1=min(y)+0.025*range(y);
y2=min(y)+0.975*range(y);
keep=(y>=y1)&(y<=y2);
p=polyfit(x(keep),y(keep),6);
xs=linspace(min(x(keep)),max(x(keep)),100);
ys=polyval(p,xs);
xs=[xs(1) xs xs(end)];
%ys=[0 ys max(y)];
ys=[0 ys max(ys)*1.50];

object.TransferTable=[ys(:) 10.^(xs(:))];

% handle output
%if nargout==0
    h=basic_figure;
    ha(1)=subplot(3,1,1);
    %image(object,ha(1));
    imagesc(object.Grid1,object.Grid2,object.Data);
    colormap(object.ColorMap);
    xlabel(object.Grid1Label);
    ylabel(object.Grid2Label);
    temp=sprintf('Wedge regions for ''%s''',object.Title);
    title(temp);
    for n=1:size(ROI,1)
        rectangle('Position',ROI(n,:),...
            'EdgeColor',get(object.PlotOptions,'LineColor'),'Tag','ROI');
    end
    ha(2)=subplot(3,1,2);
    %plot(exposure,level,'ko');
    %hold on
    errorbar(exposure,level,Dlevel,'k.');
    line(object.TransferTable(:,2),object.TransferTable(:,1));
    xlabel('Exposure');
    %hold off
    ylabel('Level');
    set(gca,'XScale','log');
    ha(3)=subplot(3,1,3);
    plot(object.TransferTable(:,1),object.TransferTable(:,2),'k');
    xlabel('Level');
    ylabel('Exposure');
    set(gca,'YScale','log');
%end

if nargout>=1
    varargout{1}=object;
end

end

function result=range(array)

result=max(array(:))-min(array(:));

end