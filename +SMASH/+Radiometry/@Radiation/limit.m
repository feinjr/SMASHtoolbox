% LIMIT Limit object to a region of interest
%
% This method defines a region of interest in a Radiation object, 
% limiting the range used in calculations and visualization.
%
% Usage:
%     >> object=limit(object,array1,array2);
% Three limit choices are available.  The choice 'all' provides no
% limit on the object range.
%    >> object=limit(object,'all');
% Passing an array of logical values allows portions of the image to be
% made active (true) or passive (false);
%    >> object=limit(object,object.Wavelength>0); % positive grid1 points only
% Active points may also be defined through a bound array, which has the
% form [lower upper].
%    >> object=limit(object,'all',[0 +inf]); % positive grid2 points.
%
% Calling this method with no inputs returns arrays from the limited
% region.
%    >> [Data,Grid1,Grid2]=limit(object);
%
% See also Radiation
%

% created March 26, 2014 by Tommy Ao (Sandia National Laboratories)
%
function varargout=limit(object,bound1,bound2)

% handle input
if nargin==1    
    if strcmp(object.LimitIndex1,'all')        
        x=object.Wavelength;
        kx=1:numel(x);
    else
        kx=object.LimitIndex1;
        x=object.Wavelength(kx);       
    end
    if strcmp(object.LimitIndex2,'all')
        y=object.Time;
        ky=1:numel(y);
    else
        ky=object.LimitIndex2;
        y=object.Time(ky);
    end
    size(object.Data);
    z=object.Data(kx,ky);
    varargout{1}=x;
    varargout{2}=y;
    varargout{3}=z;
    return
end

if nargin<3 
    bound2=[];
end

% apply first limit array
if isempty(bound1)
    % do nothing with Grid1
elseif strcmpi(bound1,'all')
    object.LimitIndex1='all';
elseif isnumeric(bound1) && (numel(bound1)==2)  
    keep=(object.Wavelength>=bound1(1)) & (object.Wavelength<bound1(2));
    assert(sum(keep)>0,'ERROR: no Grid1 points in limited region');
    index=1:numel(object.Wavelength);
    object.LimitIndex1=index(keep);       
else
     error('ERROR: invalid limit array');
end

if isnumeric(object.LimitIndex1)
    match=strcmpi(class(object.LimitIndex1),object.Precision);
    if ~match
        object.LimitIndex1=feval(object.Precision,object.LimitIndex1);
    end            
end

% apply second limit array
if isempty(bound2)
    % do nothing with Grid2
elseif strcmpi(bound2,'all')
    object.LimitIndex2='all';
elseif islogical(bound2)
    index=1:numel(object.Time);
    if numel(index)~=numel(bound2)
        error('ERROR: invalid logical array');
    end
    object.LimitIndex2=index(bound2);
elseif isnumeric(bound2) && (numel(bound2)==2)  
    keep=(object.Time>=bound2(1)) & (object.Time<bound2(2));
    assert(sum(keep)>0,'ERROR: no Grid2 points in limited region');
    index=1:numel(object.Time);
    object.LimitIndex2=index(keep);     
else
     error('ERROR: invalid limit array');
end

if isnumeric(object.LimitIndex2)
    match=strcmpi(class(object.LimitIndex2),object.Precision);
    if ~match
        object.LimitIndex2=feval(object.Precision,object.LimitIndex2);
    end            
end

% handle output
varargout{1}=object;

end