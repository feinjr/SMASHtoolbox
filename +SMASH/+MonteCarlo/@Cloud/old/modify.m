
% object=modify(object,table);
%

%
%
%
function object=modify(object,table)

assert(size(table,1)>=5,'ERROR: table has less than five rows');
object.Data=table;
[object.NumberPoints,object.NumberVariables]=size(object.Data);
[object.Moments,object.Correlations]=summarize(object);
object.Source='modify';

% update labels
if numel(object.DataLabel) ~= object.NumberVariables    
    object.DataLabel=cell(1,object.NumberVariables);
    for n=1:object.NumberVariables
        object.DataLabel{n}=sprintf('Variable #%d',n);
    end
end


end