% add Add data points 
%
% This method adds data to a CloudFitXY object.  Existing Cloud objects can
% be added directly.
%    >> object=add(object,cloud1,cloud2,...);
% Tabular data can also be added.
%     >> object=add(object,table);
% Each row of the table defines a new Cloud point, the properties of which
% are defined as shown below.
%     [xmean ymean xvar yvar xskew yskew xkurt ykurt correlation]
% The first four columns (mean and variance) of the table *must* be
% defined.
%     -Columns 5--6 (skewness) are optional and default to zero.
%     -Columns 7--8 (excess kurtosis) are optional and default to zero.
%     -Column 9 (correlation) is optional and defaults to zero.
%
% See also CloudFitXY, remove, Cloud
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised January 19, 2014 by Daniel Dolan
%   -simplified tabular input
%
function object=add(object,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient number inputs');

% process first request
if isa(varargin{1},'SMASH.MonteCarlo.Cloud') % Cloud input
    object.Clouds{end+1}=varargin{1};  
elseif isnumeric(varargin{1}) % tabular input
    table=varargin{1};
    [rows,columns]=size(table);
    assert((columns>=4) & (columns<=9),...
        'ERROR: invalid number of table columns');
    table(:,columns+1:9)=0;
    moments=nan(2,4);
    for k=1:rows
        moments(1,:)=table(1:2:7);
        moments(2,:)=table(2:2:8);
        correlation=[1 table(9); table(9) 1];
        object.Clouds{end+1}=SMASH.MonteCarlo.Cloud(...
            moments,correlation,object.CloudSize);
    end
else
    error('ERROR: invalid input');
end
object.NumberClouds=object.NumberClouds+1;
object.ActiveClouds(end+1)=true;       

% move to next request, if present
if numel(varargin)>1
    object=add(object,varargin(2:end));
end

end