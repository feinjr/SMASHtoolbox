% addCloud Add cloud(s)
%
% This method adds data to a CloudFit1 object.  Existing Cloud objects can
% be added directly.
%    >> object=add(object,cloud1,cloud2,...);
% Tabular data can also be added.
%     >> object=add(object,xmoments,ymoments,correlation,points);
% Each row of the table defines a new Cloud point with the specified
% x-y moments and correlation
 
%the properties of which
% are defined as shown below.
%     [xmean ymean xvar yvar xskew yskew xkurt ykurt correlation]
% The first four columns (mean and variance) of the table *must* be
% defined.
%     -Columns 5--6 (skewness) are optional and default to zero.
%     -Columns 7--8 (excess kurtosis) are optional and default to zero.
%     -Column 9 (correlation) is optional and defaults to zero.
%
% See also CloudFit2, removeCloud, Cloud
%

function object=addCloud(object,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');
Narg=numel(varargin);

% process first request
if isa(varargin{1},'SMASH.MonteCarlo.Cloud') % Cloud input
    for n=1:Narg
        assert(isa(varargin{n},'SMASH.MonteCarlo.Cloud'),...
            'ERROR: invalid input detected');
        object.CloudData{end+1}=varargin{n};
        object.NumberClouds=object.NumberClouds+1;
        object.ActiveClouds(end+1)=true;
    end
elseif ischar(varargin{1}) % read from file
    % UNDER CONSTRUCTION
else % process arrays
    assert(Narg>=2,'ERROR: insufficient input')
    [xrow,xcol]=size(varargin{1});
    assert(any(xcol==[2 3 4]),'ERROR: invalid number of x-moments');    
    [yrow,ycol]=size(varargin{2});
    assert(any(ycol==[2 3 4]),'ERROR: invalid number of y-moments');
    assert(xrow==yrow,'ERROR: incompatible moment tables');
    moments=zeros(2,4);
    if (Narg<3) || isempty(varargin{3})
        varargin{3}=0;
    end
    if isscalar(varargin{3})
        varargin{3}=repmat(varargin{3},[xrow 1]);
    end
    if (Narg<4) || isempty(varargin{4})
        varargin{4}=100;
    end
    assert(SMASH.General.testNumber(varargin{4},'positive','integer'),...
        'ERROR: invalid number of cloud points');

    assert(numel(varargin{3})==xrow,...
        'ERROR: incompatible correlation array');   
    correlation=eye(2,2);
    for k=1:xrow        
        moments(1,1:xcol)=varargin{1}(k,:);
        moments(2,1:ycol)=varargin{2}(k,:);
        correlation(1,2)=varargin{3}(k);
        correlation(2,1)=correlation(1,2);
        object.CloudData{end+1}=SMASH.MonteCarlo.Cloud(...
            moments,correlation,varargin{4});
        object.NumberClouds=object.NumberClouds+1;
    end    
end  

end