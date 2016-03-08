% trim Remove points from data cloud
%
% This method removes points from a data cloud.  Simple calls:
%    object=remove(object);
% remove points where any variable is infinite or NaN.
%
% Clouds can be trimmed to a fraction of their range.
%    object=trim(object,center); % center fraction, e.g. 0.90
%    object=trim(object,[low high]); % low/high fractions, e.g. [0.05 0.95]
% Logical indices may also be passed to indicate points that should be
% dropped from the cloud.
%    object=trim(object,index);
% In either case, nan/inf values should be trimmed *before* fraction or
% drop trimming.
%
% See also Cloud
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)

%
function object=trim(object,arg)

% manage input
if nargin==1
    drop=any(isnan(object.Data),2) | any(isinf(object.Data),2);
    object=trim(object,drop);
    return
end

if islogical(arg)
    assert(numel(arg)==object.NumberPoints,...
        'ERROR: drop array must match the number of cloud points');
    drop=arg;
    mode='drop';
elseif isnumeric(arg)
    if isscalar(arg)
        arg=0.50+[-0.5 +0.5]*arg;
    end
    assert(numel(arg)==2,'ERROR: invalid trim range');
    assert(all(arg>=0) && all(arg<=1),'ERROR: invalid trim range');
    range=sort(arg);
    assert(diff(range)>0,'ERROR: invalid trim range');
    mode='fraction';
else
    error('ERROR: invalid trim argument');
end

% perform trimming
table=object.Data;
switch mode
    case 'drop'
        table=table(~drop,:);
    case 'fraction'
        keep=true(object.NumberPoints,1);
        index=round(object.NumberPoints*range);
        index(1)=max(index(1),1);
        index(2)=min(index(2),object.NumberPoints);
        for n=1:object.NumberVariables
            temp=sort(table(:,n));
            bound=temp(index(1));
            keep(table(:,n)<bound)=false;
            bound=temp(index(2));
            keep(table(:,n)>bound)=false;
        end
        table=table(keep,:);
end

% manage output
object.Data=table;
object.Source='table';
object.NumberPoints=size(object.Data,1);

end