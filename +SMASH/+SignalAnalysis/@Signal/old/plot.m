% plot method for sso objects
% 
% plot(object);


function varargout=plot(object,varargin)

% create plot and apply settings
h=plot(object.Time,object.Value);
set(h,...
    'Color',object.Color,...
    'LineStyle',object.LineStyle,...
    'LineWidth',object.LineWidth,...
    'Marker',object.Marker);

for n=1:2:numel(varargin)
    
end

if numel(varargin)>0
    set(h,varargin{:});
end

xlabel(object.XLabel);
ylabel(object.YLabel);
title(object.Title);

fig=ancestor(h(1),'figure');
figure(fig);

% handle output
if nargout>1
    varargout{1}=h;
end

end