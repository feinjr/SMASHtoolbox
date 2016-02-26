% summarize Display data point values and status
%
% This method summarize the current state of the cloud fit object.  It can
% be called with output arguments to access specific information.
%    >> [x,y,status]=summarize(object);
% When called without outputs:
%    >> summarize(object);
% a report is is printed to the command window.
%
% See also CloudFitXY, activate, add, deactivate, remove
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

M=object.NumberClouds;
[x,y]=deal(nan(M,1));
status=cell(size(x));
for m=1:M;
    x(m)=object.Clouds{m}.Moments(1,1);
    y(m)=object.Clouds{m}.Moments(2,1);
    if object.ActiveClouds(m)
        status{m}='active';
    else
        status{m}='inactive';
    end
end

% handle output
if nargout==0
    label={'Cloud #','x','y','status'};
    width=max(round(log10(M)),numel(label{1}));
    format=sprintf('%%%ds',width);
    fprintf([format '%#+15s %#+15s %10s\n'],label{:});
    format=sprintf('%%%dd',width);
    for m=1:M
        fprintf([format '%#+15.6g %#+15.6g %10s\n'],...
            m,x(m),y(m),status{m});
    end    
else
    varargout{1}=x;
    varargout{2}=y;
    varargout{3}=status;
end

end