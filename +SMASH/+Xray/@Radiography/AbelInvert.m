%% 
%
% Created May 28, 2014 by Patrick Knapp (Sandia National Laboratories)

function rho_object = AbelInvert(object,varargin)

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

K = object.Opacity; %opacity in cm^2/g
Tx = object.Data;
R = object.Grid1;
Z = object.Grid2;

Tx(Tx<minTransmission) = minTransmission;

Tau = -log(Tx)/K;
rho = zeros(size(Tau));

switch method
    case 'TwoPoint'
        rho=abel(R/10,Tau);
end

rho_object = SMASH.Xray.Radiography(R,Z,rho);