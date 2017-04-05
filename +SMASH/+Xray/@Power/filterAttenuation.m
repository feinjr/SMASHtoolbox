%
%
%
% Created March 01, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
% Calculates filter transmission curves and element absorption curves to
% give total absorption curve
%
function object = calculateAbsorption(object,varargin)

% Calculate attenuation curve for detectors

%isobject(varargin{1})
%size(varargin{1}.Grid)

if isempty(object.Settings.FilterMaterial)
    
else
    NumFilts = length(object.Settings.FilterMaterial)
    
    % Energies at which filter attenuation will be calculated
    if (nargin==2) && isrow(varargin)==1
        E = varargin;
    else if (nargin==2) && isobject(varargin{1})==1
        E = varargin{1}.Grid;

    else
        E = (100:10:30000)';
        end
        
        assignin('base','E',E)
        
    Attenuation = repmat(0,NumFilts,size(E,1));
    
    % Calculate transmission plots for filters
    for i = 1:NumFilts
        
        FilterMaterial = object.Settings.FilterMaterial{i};
        AttenuationLengthCurve = dlmread(strcat('C:\Users\ajharve\Documents\MATLAB\MATLAB programs\Z data analysis\Foil attenuations\',FilterMaterial,'.txt'));

        AttenuationLengthEnergy = AttenuationLengthCurve(:,1);
        AttenuationLengthValue = AttenuationLengthCurve(:,2);
        
        Attenuationlengthfit = interp1(AttenuationLengthEnergy,AttenuationLengthValue,E);%This calculates values of the attenuationlength at the same wavelengths as the sim spectrum based on a fit of the input filter attenuation profile

        FilterThickness = object.Settings.FilterThickness(i);

        Attenuation(i,:) = exp(-FilterThickness./Attenuationlengthfit');
        plot(E,Attenuation(i,:)); hold on

    end

    TotalAttenuation = prod(Attenuation,1);
    plot(E,TotalAttenuation,'k'); hold on
    
end

% Calculate absoprtion curve for detectors
if strcmp(object.Settings.ElementType,'Pcd')==1
ElementMaterial = 'Diamond';
ElementThickness = object.Settings.ElementSize(2)
ElementAbsorptionCurve = dlmread(strcat('C:\Users\ajharve\Documents\MATLAB\MATLAB programs\Z data analysis\Foil attenuations\',ElementMaterial,'.txt'));
ElementAbsorptionValue = ElementAbsorptionCurve(:,2);
ElementAbsorptionEnergy = ElementAbsorptionCurve(:,1);
Absorptionlengthfit = interp1(AttenuationLengthEnergy,AttenuationLengthValue,E);%This calculates values of the attenuationlength at the same wavelengths as the sim spectrum based on a fit of the input filter attenuation profile
ElementAbsorption = 1-(exp(-ElementThickness./Absorptionlengthfit'));


elseif strcmp(object.Settings.ElementType,'Sid')==1    
ElementMaterial = 'Silicon';  
ElementThickness = object.Settings.ElementSize(2)
ElementAbsorptionCurve = dlmread(strcat('C:\Users\ajharve\Documents\MATLAB\MATLAB programs\Z data analysis\Foil attenuations\',ElementMaterial,'.txt'));
ElementAbsorptionValue = ElementAbsorptionCurve(:,2);
ElementAbsorptionEnergy = ElementAbsorptionCurve(:,1);
Absorptionlengthfit = interp1(ElementAbsorptionEnergy,ElementAbsorptionValue,E);%This calculates values of the attenuationlength at the same wavelengths as the sim spectrum based on a fit of the input filter attenuation profile
ElementAbsorption = 1-exp(-ElementThickness./Absorptionlengthfit');

plot(E,ElementAbsorption,'g'); hold on;

else
    ElementAbsoprtion = 1;
end

% Combine transmission curve and absorption curves
AbsorptionCurve = TotalAttenuation'.*ElementAbsorption';
plot(E,AbsorptionCurve,'r'); hold off;

object.AbsorptionCurve = SMASH.SignalAnalysis.Signal(E,AbsorptionCurve);

end

