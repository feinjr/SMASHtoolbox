function object=import(object,data)

object.Name='SignalGroup object';

if numel(data)==1 % single file (needs testing!)
    object=import@SMASH.SignalAnalysis.Signal(object,data);
    if strcmp(data.Format,'column')
        while size(data.Data,2)>2
            data.Data=data.Data(:,[1 3:end]);
            temp=import@SMASH.SignalAnalysis.Signal(object,data);            
            temp.Legend={};
            temp.Legend=cell(1,size(object.Data,2));
            object.Legend={};
            object.Legend=cell(1,size(object.Data,2));            
            object=gather(object,temp);
        end
    end
else % multiple files
    object=import(object,data(1));
    for k=2:numel(data)
        temp=import@SMASH.SignalAnalysis.Signal(object,data(k));
        object=gather(object,temp);
    end
end

% finishing details
object.NumberSignals=size(object.Data,2);
object.Legend=cell(1,object.NumberSignals);
for k=1:object.NumberSignals
    object.Legend{k}=sprintf('Signal %d',k);
end

end