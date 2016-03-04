% trim Remove outliers from cloud
%
% UNDER CONSTRUCTION

%
%
%
function object=trim(object,range)

% manage input
if (nargin<2) || isempty(range)
    range=1;
end
assert(isnumeric(range),'ERROR: invalid trim range');
if isscalar(range)
    width=range;
    range=0.50+[-0.5 +0.5]*width;
end
assert(numel(range)==2,'ERROR: invalid trim range');
assert(all(range>=0) && all(range<=1),'ERROR: invalid trim range');
range=sort(range);
assert(diff(range)>0,'ERROR: invalid trim range');

% extract data table
table=object.Data;
N=size(table,1);
keep=true(N,1);

% remove obvious problems
keep(any(isnan(table),2))=false;
keep(any(isinf(table),2))=false;

% remove extreme values
index=round(N*range);
index(1)=max(index(1),1);
index(2)=min(index(2),N);
for n=1:object.NumberVariables
    temp=sort(table(:,n));
    bound=temp(index(1));
    keep(table(:,n)<bound)=false;
    bound=temp(index(2));
    keep(table(:,n)>bound)=false;
end

% manage output
object.Data=table(keep,:);
object.Source='table';
object.NumberPoints=size(object.Data,1);

end