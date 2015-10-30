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
function varargout=view(object,target)

% manage input
new=false;
if (nargin<2) || isempty(target)
    figure;
    target=axes('Box','on');
    new=true;
end
assert(ishandle(target),'ERROR: invalid target axes');

% display active clouds
clouds=object.CloudData(object.ActiveClouds);
N=numel(clouds);
h=nan(1,N);
for n=1:N
    switch object.ViewOptions.CloudMode
        case 'ellipses'
            [x,y]=ellipse(clouds{n},[1 2],...
                object.ViewOptions.CloudEllipseSpan);
            h(n)=line(x,y,'Parent',target,...
                'Marker','none',...
                'LineStyle',object.ViewOptions.CloudLineStyle);
        case 'means'
            x=clouds{n}.Moments(1,1);
            y=clouds{n}.Moments(2,1);
            h(n)=line(x,y,'Parent',target,...
                'Marker',object.ViewOptions.CloudMarker,...
                'LineStyle','none');
        case 'points'
            x=clouds{n}.Data(:,1);
            y=clouds{n}.Data(:,2);
            h(n)=line(x,y,'Parent',target,...
                'Marker',object.ViewOptions.CloudMarker,...
                'LineStyle','none');
    end
    set(h(n),'Color',object.ViewOptions.CloudColor);
end

if new
    xlabel(object.ViewOptions.XLabel);
    ylabel(object.ViewOptions.YLabel);
end

% display model curve (if available)
if ~isempty(object.Model)
    object.Model=evaluate(object.Model,[],xlim(target),ylim(target));
    view(object.Model.Curve,gca);
end

% handle output
if nargout>0
    varargout{1}=h;
end

end