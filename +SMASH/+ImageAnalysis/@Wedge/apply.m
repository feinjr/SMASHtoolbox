% APPLY Apply Wedge transfer table (object) to an Image (target)
%
%   >> target=apply(object,target);
%
% See also ImageAnalysis, Wedge, analyze
%

% created December 5, 2013 by Tommy Ao (Sandia National Laboratories)
%
%%
function target=apply(object,target)
% handle input
if nargin<2
    error('ERROR: insufficient number of inputs');
end

if ~isa(target,'SMASH.ImageAnalysis.Image')
    error('ERROR: wedge transfer can only be applied to Image objects');
end
    
% map z coordinate using wedge transfer table
table=object.TransferTable;
table=sortrows(table,1);
table(2:end+1,:)=table;
table(1,:)=nan;
table(end+1,:)=nan;

table(1,1)=min(object.Data(:));
table(1,2)=table(2,2);
table(end,1)=max(object.Data(:));
table(end,2)=table(end-1,2);

target=map(target,'Data','table',table);
target=updateHistory(target);

end