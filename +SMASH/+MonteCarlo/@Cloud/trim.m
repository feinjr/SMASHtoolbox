% trim Remove points from data cloud
%
% This method removes points from a data cloud.  Simple calls:
%    object=trim(object);
% remove points where any variable is infinite or NaN.  Cloud points may
% also be removed by passing a logical array; true values indicate points
% to be removed .
%    object=trim(object,drop);
% The input "drop" must have the same number of elements as the number of
% cloud points. 
%
% Clouds can be trimmed by the span of a particular variable.
%    object=trim(object,variable,span);
% The input "variable" must be value variable index for the cloud.  The
% input "span" indicates the trim range in percentiles.  For example:
%    object=trim(object,0.90); % trim to central 90%
%    object=trim(object,[low high]); % low/high fractions, e.g. [0.05 0.95]
% Nan/inf values should be removed *before* trimming to a variable span.
%
% See also Cloud
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=trim(object,varargin)

% manage input
if nargin==1
    drop=any(isnan(object.Data),2) | any(isinf(object.Data),2);
    object=trim(object,drop);
    return
end

Narg=numel(varargin);

% perform trimming
table=object.Data;
if (Narg==1) && islogical(varargin{1})
    assert(numel(varargin{1})==object.NumberPoints,...
        'ERROR: drop array must match the number of cloud points');
    drop=varargin{1};
    table=table(~drop,:);    
else
    assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
    keep=true(object.NumberPoints,1);
    ValidVariable=1:object.NumberVariables;        
    for n=1:2:Narg
        variable=varargin{n};
        assert(any(variable==ValidVariable),'ERROR: invalid variable index');
        span=varargin{n+1};
        assert(isnumeric(span),'ERROR: invalid trim span');
        if isscalar(span)
            span=0.50+[-0.5 +0.5]*span;
        end
        assert(numel(span)==2,'ERROR: invalid trim span');
        assert(all(span>=0) && all(span<=1),'ERROR: invalid trim span');
        index=round(object.NumberPoints*span);
        index(1)=max(index(1),1);
        index(2)=min(index(2),object.NumberPoints);
        temp=sort(table(:,variable));
        bound=temp(index(1));
        keep(table(:,variable)<bound)=false;
        bound=temp(index(2));
        keep(table(:,variable)>bound)=false;
    end
    table=table(keep,:);
end     

% manage output
object.Data=table;
object.Source='table';
object.NumberPoints=size(object.Data,1);

end