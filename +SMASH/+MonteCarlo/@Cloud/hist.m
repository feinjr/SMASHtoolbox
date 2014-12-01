% hist Create 1D/2D histograms of Cloud data
%
% This method generates one- and two-dimensional histograms for variables
% inside of a data cloud.  The choice of variable(s) is specified by the
% second input argument.
%    >> hist(object,2); % 1D histogram of variable 2
%    >> hist(object,[1 3]); % 2D histogram of variables 1 and 3
% The second input is required unless the cloud only has two variables, in
% which case the histogram defaults to the first and second variables.  If
% the input is omitted in any other case, the user will be prompted to
% select one or two variables before the histogram can be generatd.
%
% Options for controlling the histogram are specified as name/value pairs.
%    >> hist(object,variable,'Name',value);
% Valid options are specified below.
%    -'bin'/'xbin'/'hbin' : horizontal bin specification
%    -'ybin'/'vbin'       : vertical bin specification (2D histograms only)
%    -'target'            : axes handle where histogram is to be placed
% Like MATLAB'S standard hist function, two types of binning are supported.
%  If a single integer is specified, it is understood to mean that this is
%  the number of bins that are to be used and the bin locations are chosen
%  automatically.  Specific bin locations can be defined by passing an
%  array of numbers.
%
% As in MATLAB's bin function, the use of outputs suppresses plot generation.
%    >> [count,bin]=hist(object,...); % 1D histogram
%    >> [count,xbin,ybin]=hist(object,...); % 2D histogram
%
% See also Cloud, ellipse, view
%

% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
% revised August 5, 2014 by Daniel Dolan
%    -modifed input handling
% revised August 8, 2014 by Daniel Dolan
%    -changed output handling to match MATLAB hist convention
%
function varargout=hist(object,variable,varargin)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many plot variables');
for k=1:numel(variable)
    assert(SMASH.General.testNumber(variable(k),'positive','integer') & ...
        variable(k)>0 & variable(k)<=object.NumberVariables,...
        'ERROR: invalid variable number');
end

N=numel(varargin);
if rem(N,2)==1
    error('ERROR: unbalanced name/value pair');
end
xbin=10;
ybin=10;
target=[];
for k=1:2:N
    name=varargin{k};
    value=varargin{k+1};
    switch lower(name)
        case {'bin','bins','xbin','hbin'}
            xbin=value;
        case {'ybin','vbin'}
            ybin=value;
        case 'target'
            target=value;
        otherwise
            error('ERROR: %s is an unrecognized input name',name);
    end
end

if isempty(target)
    target=gca;
elseif ishandle(target) && strcmpi(get(target,'Type'),'axes')
    % do nothing
else
      error('ERROR: invalid axes handle');
end

% generate histograms
switch numel(variable)
    case 1
        [count,xbin]=hist(object.Data(:,variable(1)),xbin);
    case 2
        x=object.Data(:,variable(1));
        y=object.Data(:,variable(2));
        if numel(xbin)==1
            xbin=linspace(min(x),max(x),xbin);
        end
        if numel(ybin)==1
            ybin=linspace(min(y),max(y),ybin);
        end
        count=zeros(numel(ybin),numel(xbin));
        left=[-inf xbin(1:end-1)];
        right=[xbin(2:end) +inf];
        for n=1:numel(xbin)
            index=(x>=left(n)) & (x<right(n));
            temp=hist(y(index),ybin);
            count(:,n)=temp(:);
        end
        
end

% handle ouput
if nargout==0
    axes(target);
    switch numel(variable)
        case 1
            bar(xbin,count,'hist');
            xlabel(target,object.DataLabel{1});
            ylabel(target,'Number of counts');
        case 2
            imagesc(xbin,ybin,count);
            set(target,'YDir','normal');
            xlabel(target,object.DataLabel{variable(1)});
            ylabel(target,object.DataLabel{variable(2)});
    end
else
    switch numel(variable)
        case 1
            varargout{1}=count;
            varargout{2}=xbin;
        case 2
            varargout{1}=count;
            varargout{2}=xbin;
            varargout{3}=ybin;
    end
end

end