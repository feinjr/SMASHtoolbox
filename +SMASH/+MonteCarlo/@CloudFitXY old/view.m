% view Data and cloud visualization
%
% This method provides several visualizations for a CloudFitXY object.
%    >> view(object,'data'); % data points
%    >> view(object,'cloud'); % cloud points
%    >> view(object,'ellipse'); % 1-sigma bounding ellipse for each cloud
% Each mode draws on the current axes.
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode)

% handle input
if (nargin<2) || isempty(mode)
    mode='data';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);

% display active clouds
clouds=getActiveClouds(object);
Nactive=numel(clouds);
color=lines(Nactive);
h=nan(1,Nactive);
for k=1:Nactive
    temp=clouds{k};
    switch mode
        case 'data'
            x=temp.Moments(1,1);
            y=temp.Moments(2,1);
            h(k)=line(x,y);
            apply(object.GraphicOptions,h(k),'noparent');
            set(h(k),'LineStyle','none','Color',color(k,:))
        case {'cloud','clouds'}
            x=temp.Data(:,1);
            y=temp.Data(:,2);
            h(k)=line(x,y);
            apply(object.GraphicOptions,h(k),'noparent');
            set(h(k),'LineStyle','none','Color',color(k,:));
        case 'ellipse'
            [x,y]=ellipse(temp);            
            h(k)=line(x,y);
            apply(object.GraphicOptions,h(k),'noparent');
            set(h(k),'Marker','none','Color',color(k,:));
        otherwise
            error('ERROR: invalid view mode');
    end
end

xlabel(object.XLabel);
ylabel(object.YLabel);

% handle output
if nargout>0
    varargout{1}=h;
end

end