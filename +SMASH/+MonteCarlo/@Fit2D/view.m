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
function varargout=view(object)


assert(object.Processed,...
    'ERROR: measurement(s) must be processeed before viewing');

figure;
axes('Box','on');
xlabel(object.DisplaySettings.XLabel);
ylabel(object.DisplaySettings.YLabel);

for n=1:object.NumberMeasurements
    temp=object.ProcessedResult{n}.Boundary;
    line(temp(:,1),temp(:,2));
end



% if new
%     xlabel(object.ViewOptions.XLabel);
%     ylabel(object.ViewOptions.YLabel);
% end
% 
% % display model curve (if available)
% if ~isempty(object.Model) && ~isempty(object.Model.Curve)
%     line(object.Model.Curve(:,1),object.Model.Curve(:,2),...
%         'Parent',target,...
%         'Color',object.ViewOptions.ModelColor,...
%         'LineStyle',object.ViewOptions.ModelLineStyle);
% end

% handle output
if nargout>0
    varargout{1}=h;
end

end