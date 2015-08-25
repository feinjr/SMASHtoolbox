
function target=apply(object,target)
% handle input
if nargin<2
    error('ERROR: insufficient number of inputs');
end

if ~isa(target,'SMASH.ImageAnalysis.Image')
    error('ERROR: step wedge transfer can only be applied to Image objects');
end

% prepare table
table=object.TransferTable;
table=sortrows(table,1);

% locate values outside of the table
index1=(target.Data<table(1,1));
index2=(target.Data>table(end,1));

% map z coordinate using wedge transfer table
target=map(target,'Data','table',table);
target.Data(index1)=table(1,2);
target.Data(index2)=table(end,2);
