%% 
%
% Created May 28, 2014 by Patrick Knapp (Sandia National Laboratories)

function object = abelInvert(object,varargin)

% Default parameters
minTransmission = 1e-3;
method = 'TwoPoint';

% Parse variable inputs
if length(varargin)>1
   for i = 1:length(varargin)
      if strcmp(varargin{i},'method')
          method = varargin{i+1};
      elseif strcmp(varargin{i},'Minimum')
          minTransmission = varargin{i+1};
      end
   end
end

K = object.Settings.Opacity; %opacity in cm^2/g
Tx = object.Transmission.Data;
R = object.Transmission.Grid1;
Z = object.Transmission.Grid2;

Tx(Tx<minTransmission) = minTransmission;

Tau = -log(Tx)/K;
rho = zeros(size(Tau));

switch method
    case 'TwoPoint'
        rho=abel(R/10,Tau);
end

object.Density = SMASH.ImageAnalysis.Image(R,Z,rho);
object.Density.GraphicOptions.Title = 'Abel Inverted Density';
object.Density.Grid1Label = 'Radius [mm]';
object.Density.Grid2Label = 'Height [mm]';
object.Density.DataLabel = 'Density [g/cm^3]';
