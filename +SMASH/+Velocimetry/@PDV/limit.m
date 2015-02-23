% limit Limit object to a region of interest
%
% This method defines a region of interest in a PDV object, limiting the
% time range used in calculations and visualization.
%     >> object=limit(object,[tmin tmax]); % specify limited region
%     >> object=limit(object,'all'); % use all times
%
% Limits can also be selected manually.
%     >> object=limit(object,'manual');
% Manual selection displays the object's preview and waits for the user to
% press the "Done" button.
%
% See also PDV
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=limit(object,varargin)

% manage input
Narg=numel(varargin);
if Narg==0
    object=limit(object,'manual');
elseif (Narg==1) && strcmpi(varargin{1},'manual')
    preview(object);
    title(gca,'Use zoom/pan to select limit region');   
    hc=uicontrol('Parent',gcf,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound=xlim;    
    close(gcf);
    object=limit(object,bound);    
else
    object.Measurement=limit(object.Measurement,varargin{:});
end

end