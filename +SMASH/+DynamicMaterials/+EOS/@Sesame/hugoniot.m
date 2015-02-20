% HUGONIOT Generate Hugoniot curve from sesame table object
%
% This method returns the new Hugoniot sesame object for the array of
% of densities, initial pressure (P0), initial density (rho0), and initial
% particle velocity, up1.
%
% Usage:
%    >> new=hugoniot(object,density)
%    >> new=hugoniot(object,density,P0,rho0,up1)
%    
% The initial conditions are used to interpolate for the initial energy,
% and then 'fzero' is used to solve the Rankine-Hugoniot equation to 
% determine the other variables. The data array is used to store the 
% calculated particle and shock velocities. If no initial conditions are 
% specified, STP conditions are used.
%
% See also Sesame, isentrope, isobar, isochor, isotherm
%

% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=hugoniot(varargin)

% Error checking
if (nargin<2) 
    error('Invalid input. Require at least (obj,density);');
end

%Input initialization
object = varargin{1};
density = varargin{2};
P0 = 0;
rho0 = stp(object,density(1)); rho0 = rho0.Density;
up1 = 0;

if nargin > 2
    P0 = varargin{3};
end
if nargin > 3
    rho0 = varargin{4};
end    
if nargin > 4
    up1 = varargin{5};
end  

% Error checking
if (nargin<2) || isempty(density)
    error('Invalid input. Require at least (obj,density);');
end

if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

%Lookup initial temperature and energy
if P0 < 1e-3
    T0 = 298.0;
else
    T0 = reverselookup(object,'Pressure',P0,rho0);
end
T0 = fzero(@(x) lookup(object,'Pressure',rho0,x)-P0,T0);
E0 = lookup(object,'Energy',rho0,T0);

temperature = nan(size(density));

%w = SMASH.MUI.Waitbar('Calculating Hugniot Points');


%% Solve Rankine-Hugoniot jump conditions using fzero
 options = optimset('TolX',1e-4);
 temperature(1) = fzero(@(x) lookup(object,'Energy',density(1),x)-E0 ...
      -0.5.*(lookup(object,'Pressure',density(1),x)+P0).*(1/rho0-1/density(1)),T0,options);
 
 for i = 2:length(density);
     temperature(i) = fzero(@(x) lookup(object,'Energy',density(i),x)-E0 ...
      -0.5.*(lookup(object,'Pressure',density(i),x)+P0).*(1/rho0-1/density(i)),temperature(i-1),options);
     %update(w,i/length(density));
 end


%% Newton-Raphson solution to Hugoniot jump conditions
% for v = 1:length(density)
%     d = density(v);
%     
%     % Guess temperature
%     if v > 1
%         t = temperature(v-1);
%     else
%         t = T0;
%     end    
%     
%     tol=1e-4; mult = 1.0; iternum=20;
%     
%     [e,dedd,dedt] = lookup(object,'Energy',d,t);
%     [p,dpdd,dpdt] = lookup(object,'Pressure',d,t);
%     check = e-E0 - 0.5.*(p-P0).*(1/rho0-1/d);
%     tnew = t;
%     
%     for iter=1:iternum
%         if (tnew < 0)
%             tnew = t*3/2;
%         end
%         while (tnew > max(object.Temperature))
%             tnew = tnew*.9;
%         end
%         t = tnew;
%         [e,dedd,dedt] = lookup(object,'Energy',d,t);
%         [p,dpdd,dpdt] = lookup(object,'Pressure',d,t);
%         
%         %Check new temperature
%         check = e-E0 - 0.5.*(p-P0).*(1/rho0-1/d);
%         if abs(check)<tol; break; end;
%     
%         %Newton-Raphson update if it hasn't converged
%         tnew = t-mult.*(check./(dedt-0.5.*dpdt.*(1/rho0-1/d)));
%     end
% 
%     if abs(check) > tol;
%         warning('Warning: convergence not achieved for density = %f, energy tol = %f',d,check);
%     end
%     temperature(v) = t;
% end


pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

%Find us and up. Interpolate where density = rho0
okrange = rho0 ~= density;
Us(okrange,:) = sqrt(abs((pressure(okrange)-P0)./(rho0-rho0^2./density(okrange))));
up(okrange,:) = (pressure(okrange)-P0)./(rho0.*Us(okrange))+up1;
up(~okrange,:) = up1;
fit = polyfit(up(okrange),Us(okrange),2);
Us(~okrange,:)=polyval(fit,up(~okrange));

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=up;
new.Data{2}=Us;

%Set some properties
new.Name='Hugoniot';
new.Source = 'Calculated';
new.SourceFormat='hugoniot';

end


