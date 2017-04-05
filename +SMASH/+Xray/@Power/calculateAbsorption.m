%
%
%
% Created March 10, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
% Calculates filter transmission curves from a Power object using ColdOpacity class
%
function object = calculateAbsorption(object,varargin)

%% Calculate transmission of filters


if (nargin==1) && isempty(object.Spectrum) 
         Energy = [100,100000,1000];
    elseif nargin
         Energy = [min(object.Spectrum.Grid),max(object.Spectrum.Grid),1000];
    else
        Energy = varargin;
end
%assignin('base','Energy',Energy)
 
SignalNumber = size(object.Settings,2)-1;
Signals = 1:SignalNumber;

j=0;
for i=Signals

if isempty(object.Settings(6,i+1));    
FilterOpacity.Transmission.Data=0 ;

else

    FilterMaterials = cellstr(object.Settings{6,i+1});
    
if size(object.Settings{7,i+1},2)>1    
    FilterThickness = object.Settings{7,i+1};
else
    FilterThickness = cell2mat(object.Settings{7,i+1});
end

        FilterOpacity = SMASH.Xray.ColdOpacity('Material',FilterMaterials,'Thickness',...
        FilterThickness,'Energy', Energy);
   
end

%% Calculate absorption by element

if strcmpi(object.Settings{2,i+1},'Sid')==1
        ElementMaterial = 'Silicon';
        ElementDensity = 2.329; %g/cc
elseif strcmpi(object.Settings{2,i+1},'Pcd')==1
        ElementMaterial = 'Carbon';
        ElementDensity = 3.51; %g/cc
else
end

Element = cell2mat(object.Settings{3,i+1});
ElementThickness = Element(2);

ElementOpacity = SMASH.Xray.ColdOpacity('Material',ElementMaterial,'Thickness',...
        ElementThickness,'Energy', Energy, 'Density', ElementDensity); 

%% Calculate absorption curve
j=j+1;
TotalAbsorption(:,j) = FilterOpacity.Transmission.Data(:,end);%(1-ElementOpacity.Transmission.Data(:,end)).*FilterOpacity.Transmission.Data(:,end);

end
EnergyGrid = ElementOpacity.Transmission.Grid;
object.AbsorptionCurve = SMASH.SignalAnalysis.SignalGroup(EnergyGrid',TotalAbsorption);
object.AbsorptionCurve.Legend = object.Settings(1,2:end);
object.AbsorptionCurve.GridLabel = 'Photon energy (eV)';
object.AbsorptionCurve.DataLabel = 'Element absorption fraction';
end

