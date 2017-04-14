%
%
%
%
%
function object = subtractBaseline(object,varargin)

if nargin == 1
    SignalNumber = size(object.Settings,2)-1;
    Signals = 1:SignalNumber;
else
    Signals = varargin{1};
end


for i = Signals;
Baseline =  object.Settings{12,i+1};  
BaselineData(:,i) = object.RawSignal.Data(:,i)-Baseline;
%BaselineData = BaselineData(~isnan(BaselineData)); %Remove NAN from data     
end
%BaselineData = BaselineData(~isnan(BaselineData)); %Remove NAN from data  
object.ProcessedSignal = SMASH.SignalAnalysis.SignalGroup(object.RawSignal.Grid,BaselineData);
object.ProcessedSignal = mend(object.ProcessedSignal);
object.ProcessedSignal.Legend = object.RawSignal.Legend;
object.ProcessedSignal.GridLabel = object.RawSignal.GridLabel;
object.ProcessedSignal.DataLabel = object.RawSignal.DataLabel;

end

