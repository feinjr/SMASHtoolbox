% ellipse Generate bounding ellipse
% 
% This method estimates a 2D bounding ellipse that spans a fraction of
% the points in a data cloud.
%    >> [x,y]=ellipse(object);
% If the Cloud spans three or more dimensions, the user is prompted to
% select two variables for the ellipse; variables can also be specified
% directly.
%    >> [x,y]=ellipse(object,[1 3]); % select first and third variable
% The default ellipse span is exp(-1), but this value can be changed by
% passing a third input between 0 and 1.
%    >> [x,y]=ellipse(object,variable,span); % span 90% of the cloud
%
% Note that the number of points in the cloud strongly affects the
% performance of this method.  If too few points are specified, the
% bounding ellipse won't be very accurate.  At the same time, the ellipse
% calculation becomes very slow for very large data clouds.  Recommended
% cloud sizes for this method are 1,000 to 10,000 points.
%
% See also Cloud, hist, view
%

% created July 23, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2014 by Daniel Dolan
%    -Fixed a matrix transpose bug
%    -Modified input handling
function varargout=ellipse(object,variable,span)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'match');
end
assert(numel(variable)==2 & ...
    SMASH.General.testNumber(variable(1),'positive','integer') & ...
    SMASH.General.testNumber(variable(2),'positive','integer') & ...
    all(variable>0) & all(variable<=object.NumberVariables),...
    'ERROR: invalid variable selection');

if (nargin<3) || isempty(span)
    span=erf(1/sqrt(2));
else
    assert(SMASH.General.testNumber(span,'positive')...
        & (span>0) & (span<1),...
        'ERROR: invalid span')
end

% extract data
xc=object.Data(:,variable(1));
yc=object.Data(:,variable(2));
%moment=object.Moments(:,variable);
moment=object.Moments(variable,:);
correlation=object.Correlations(variable(1),variable(2));
correlation=[1 correlation; correlation 1];

% identify confidence domain
target=@(x) erf(x/sqrt(2)).^2-span;
low=fzero(target,1); % guess value
high=low+0.5;
low=low-0.5;
    function [err,value]=residual(sigma)
        %[x,y]=pdomain(transpose(moment),correlation,sigma);
        [x,y]=pdomain(moment,correlation,sigma);
        value=inpolygon(xc,yc,x,y);
        value=sum(value)/object.NumberPoints;
        err=value-span;
    end
options=optimset('Display','none','TolX',0.001);
%options=optimset('Display','iter','TolX',0.01);
sigma=fzero(@residual,[low high],options);
[~,value]=residual(sigma);

% handle output
if nargout==0
    h=plot(x,y);
    set(h,'Color',object.GraphicOptions.LineColor);
    xlabel(object.DataLabel{variable(1)});
    ylabel(object.DataLabel{variable(2)});
else    
    varargout{1}=x(:);   
    varargout{2}=y(:);
    varargout{3}=value;
end

end