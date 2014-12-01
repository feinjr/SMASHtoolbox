% HUGONIOT Generate Hugoniot curve from sesame table object
%
% This method returns the new Hugoniot sesame object for the array of
% of temperatures, initial pressure (P0), initial density (rho0), and initial
% particle velocity, up1.
%
% Usage:
%    >> new=hugoniot(object,temperature)
%    >> new=hugoniot(object,temperature,P0,T0,up1)
%    
% The initial conditions are used to interpolate for the initial energy,
% and then 'fzero' is used to solve the Rankine-Hugoniot equation to 
% determine the other variables. The data array is used to store the 
% calculated particle and shock velocities. If no initial conditions are 
% specified, STP conditions are used.
%
% See also Sesame, stp, isentrope, isobar, isochor, isotherm
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=hugoniot(varargin)

% Error checking
if (nargin<2) 
    error('Invalid input. Require at least (obj,density);');
end

%Input initialization
object = varargin{1};
temperature = varargin{2};
P0 = 100e-6;
T0 = 298.15;
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
if (nargin<2) || isempty(temperature)
    error('Invalid input. Require at least (obj,density);');
end

if ~isnumeric(temperature) || min(size(temperature)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

%Lookup initial density and energy
rho0 = mean(object.Density);
rho0 = fzero(@(x) lookup(object,'Pressure',x,T0)-P0,rho0);
E0 = lookup(object,'Energy',rho0,T0);

density = nan(size(temperature));

w = SMASH.MUI.Waitbar('Calculating Hugniot Points');


% Solve Rankine-Hugoniot jump conditions using fzero
density(1) = fzero(@(x) lookup(object,'Energy',x,temperature(1))-E0 ...
     -0.5.*(lookup(object,'Pressure',x,temperature(1))+P0).*(1/rho0-1/x),rho0);

for i = 2:length(density);
    density(i) = fzero(@(x) lookup(object,'Energy',x,temperature(i))-E0 ...
        -0.5.*(lookup(object,'Pressure',x,temperature(i))+P0).*(1/rho0-1/x),density(i-1));
    update(w,i/length(density));
end


% %Newton-Raphson solution to Hugoniot jump conditions
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
%     tol=1e-6; mult = 1; iternum=20;
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
%         t = tnew; check_old = check;
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
%     update(w,v/length(density));
%     if abs(check) > tol; 
%         warning('Warning: convergence not achieved, tol = %f',check);
%     end
%     temperature(v) = t;
% end

delete(w);

pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);
Us = sqrt(abs((pressure-P0)./(rho0-rho0^2./density)));
up = (pressure-P0)./(rho0.*Us)+up1;

new = SMASH.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=up;
new.Data{2}=Us;

%Set some properties
new.Name='Hugoniot';
new.Source = 'Calculated';
new.SourceFormat='hugoniot';

end



