%
%
% created February 28, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
% Calculates energy absorbed by the diode element based on calibrations
function object = calculatePower(object,varargin)

%TempGroup = object.RawSignal
if nargin == 1
    SignalNumber = size(object.Settings,2)-1;
    Signals = 1:SignalNumber;
else
    Signals = varargin{1};
end

for i=Signals


ElementSensitivity = cell2mat(object.Settings{4,i+1});
TempSensitivity = ElementSensitivity(1);
TempSensitivityError = ElementSensitivity(2);
TempImpedance = 50; %Impedance of recording system
TempGrid = object.ProcessedSignal.Grid;

TempData = object.ProcessedSignal.Data(:,i);

% Apply bias corrections to signals and calculate energy absorbed

if strcmpi(object.Settings{2,i+1},'Sid')==1
    TempData=TempData./(1-(TempData/50));
    TempData = 0.98*TempData./(TempImpedance*TempSensitivity); %0.98 accounts for fluorescence
    
elseif strcmpi(object.Settings{2,i+1},'Pcd')==1
    TempData=TempData./(1-(TempData/100));
    TempData = TempData./(TempImpedance*TempSensitivity);
else
end

% Apply correction based on collection area and source distance and apply additional correction assuming radiator is
% average of 4pi/lambertian

Element = cell2mat(object.Settings{3,i+1});
ElementArea = Element(1)*1e-6;
SourceDistance = cell2mat(object.Settings(5,i+1));

GeometryCorrection = cell2mat(object.Settings(14,i+1));

DistanceCorrection = 4*3.141*SourceDistance^2/ElementArea;
object.Settings{15,i+1} = DistanceCorrection;
ApertureCorrection = cell2mat(object.Settings(8,i+1))/cell2mat(object.Settings(9,i+1));
CorrectionFactor = GeometryCorrection*DistanceCorrection*ApertureCorrection;

TempGroup(:,i) = TempData.*CorrectionFactor;

end

object.SourcePower = SMASH.SignalAnalysis.SignalGroup(TempGrid,TempGroup);
object.SourcePower.Legend = object.RawSignal.Legend;
object.SourcePower.GridLabel = 'Time (s)';
object.SourcePower.DataLabel = 'Power (W)';
end
