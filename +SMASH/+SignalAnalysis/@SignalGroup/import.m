function object=import(object,data)

object.Name='SignalGroup object';

% multiple files
if numel(data)>1
    object=import(object,data(1));
    for k=2:numel(data)
        temp=import@SMASH.SignalAnalysis.Signal(object,data(k));
        object=gather(object,temp);
        object.Legend{k}=sprintf('signal %d',k);
    end
    object.NumberSignals=numel(data);
    return
end

object=import@SMASH.SignalAnalysis.Signal(object,data);
object.NumberSignals=1;
object.Legend={'signal 1'};

end