%
%
% created February 28, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
function object = integrateSignal(object,varargin)

if nargin == 1
    SignalNumber = size(object.Settings,2)-1
    Signals = 1:SignalNumber
else
    Signals = varargin{1}
end

%% Integrate ZBL diode signal and normalize

SignalGrid = object.SourcePower.Grid;

for i=Signals
SignalData = object.SourcePower.Data(:,i);

IntegrationLimits = cell2mat(object.Settings{11,i+1})

if IntegrationLimits(2)>IntegrationLimits(1)

[~,SignalStartInd]=min(abs(IntegrationLimits(1)-SignalGrid(:,1)));

[~,SignalEndInd]=min(abs(IntegrationLimits(2)-SignalGrid(:,1)));

SignalCut = [SignalGrid(SignalStartInd:SignalEndInd) SignalData(SignalStartInd:SignalEndInd)]

InTrapzSignal = trapz(SignalCut(:,1),SignalCut(:,2));

object.AnalysisSummary{9,i+1} = InTrapzSignal;

%% Calculate energy absorbed by detector

GeometryCorrection = cell2mat(object.Settings(14,i+1));
DistanceCorrection = cell2mat(object.Settings(15,i+1))
ApertureCorrection = cell2mat(object.Settings(8,i+1))/cell2mat(object.Settings(9,i+1))
CorrectionFactor = GeometryCorrection*DistanceCorrection*ApertureCorrection;

DetectorEnergy = InTrapzSignal/CorrectionFactor;

object.AnalysisSummary{7,i+1} = DetectorEnergy

else
    disp('Integration limits are not valid')
end

end    
end