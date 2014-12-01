% ISENTROPE  Generate a curve of constant entropy from a sesame table object
%
% This method returns the new isentrope object for the input array
% of densities, initial pressure (P0), initial density (rho), and initial
% particle velocity up1. 
%
%    Usage:
%    >> new =isentrope(object,density)
%    >> new =isentrope(object,density,P0,rho0,up1)
%
% The initial conditions are used to interpolate for the initial entropy,
% and then interploation of the density and (fixed) entropy grids are used to
% determine the other thermodynamic variables. The LAGRANGIAN soundspeed is
% determined by numerically differentiating the pressure and density and the
% particle velocity is determined by integrating along the isentrope from
% up1. If P0, rho0, and up1 are not specified they are set to SATP conditions. 
%
% See also Sesame, hugoniot, isobar, isochor, isotherm
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=isentrope(varargin)

% Error checking
if (nargin<2) 
    error('Invalid input. Require at least (obj,density);');
end

%Input initialization
object = varargin{1};
density = varargin{2};

%Assume STP
rho0 = stp(object,density(1)); P0 = rho0.Pressure; rho0 = rho0.Density;
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

if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

%Lookup initial state
T0 = reverselookup(object,'Pressure',P0,rho0);
T0 = fzero(@(x) lookup(object,'Pressure',rho0,x)-P0,T0);
S0 = lookup(object,'Entropy',rho0,T0);
%E0 = lookup(object,'Density','Temperature','Energy',rho0,T0);


%If there is no entropy table then integrate PVT
if mean(isfinite(object.Entropy)) < 0.9
    disp('WARNING: Invalid entropy table detected, using thermodynamic integration');
   
    %Solve up to density(1) (10 points) using initial conditions
    if rho0 < density(1)        
        dinitial = linspace(rho0,density(1),10)';
        Tinitial = IntPVT(object,dinitial,T0);
        T1 = Tinitial(end);
    else
        T1 = T0;
    end
    
    %Solve for isentrope from initial conditions
    temperature = IntPVT(object,density,T1);
      
    pressure = lookup(object,'Pressure',density,temperature);
    energy = lookup(object,'Energy',density,temperature);
    entropy = zeros(size(density));   
else

    %Find temperatures along isentrope through reverse lookup. If there is a problem, use the PVT integration.   
    temperature = reverselookup(object,'Entropy',repmat(S0,size(density)),density);
    pressure = lookup(object,'Pressure',density,temperature);
    energy = lookup(object,'Energy',density,temperature);
    entropy = lookup(object,'Entropy',density,temperature);

    % Check thermodynamic consistency: E = PdV
    if numel(density) > 1
        check = find(abs(1+(energy-energy(1))./cumtrapz(1./density,pressure)) > .01 & energy > max(energy)*.1);
        if check 
            disp('WARNING: thermodynamic inconsistency detected in reverse lookup, using integration instead');
            %figure; plot(density,energy,density,-cumtrapz(1./density,pressure)+energy(1))

            %Solve up to density(1) (10 points) using initial conditions
            if rho0 < density(1)        
                dinitial = linspace(rho0,density(1),10)';
                Tinitial = IntPVT(object,dinitial,T0);
                T1 = Tinitial(end);
            else
                T1 = T0;
            end

            %Solve for isentrope
            temperature = IntPVT(object,density,T1);

            pressure = lookup(object,'Pressure',density,temperature);
            energy = lookup(object,'Energy',density,temperature);
            entropy = lookup(object,'Entropy',density,temperature); 
        end
    end

end
        

%Calculate soundspeed
cb = zeros(size(density)); up = cb;

if numel(density) > 1
%cb = diff(pressure)./diff(density); cb(end+1)=cb(end); cb = sqrt(cb); 
cb = quaddiff(density,pressure); 
cb = sqrt(abs(cb));

%Compute particle velocities
up = up1 + cumtrapz(density,cb./density);

%Convert from Eulerian to Lagrangian
cb = cb.*density./rho0;
end

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=up;
new.Data{2}=cb;

%Set some properties
new.Name='Isentrope';
new.Source = 'Calculated';
new.SourceFormat='isentrope';

end


%Solves dt/dt|s = -T (dp/dt)|v / (de/dt)|v  
%For each density point, a fixed point iteration on T is performed using
%the derivatives from the lookup. A maximum of 10 iterations is performed
%before moving to the next density if 0.1% in T is  not achieved.
function temperature = IntPVT(object,density,T0)
    %t = repmat(T0,size(density));
    Tend = density(end)./density(1).*T0;
    temperature = density.*(Tend-T0)./(density(end)-density(1));

    for count = 1:10
        t = temperature;
        dpdt = zeros(size(t));
        dedt = zeros(size(t));

        for i = 1:length(density)
            [~,~,dt] = lookup(object,'Pressure',density(i),temperature(i));
            [~,~,de] = lookup(object,'Energy',density(i),temperature(i));
            dpdt(i) = dt;
            dedt(i) = de;            
        end
        temperature = cumtrapz(1./density,-t.*dpdt./dedt)+T0;
        check = sqrt(sum((temperature-t).^2))/length(temperature);
        if check < .001
            break
        end
        
        if count == 1
            %w = SMASH.MUI.Waitbar('Calculating Isentrope');
        elseif count > 1
            %update(w,count/10);
        end
    end
    if count == 10
        disp(sprintf('WARNING: Integration did not converge, LSE = %e',check))
    %elseif exist('w'); delete(w); 
    end
end


%Function performs a quadratic differentiation of f(x). Consistent with
%Kerley's use.
function df = quaddiff(x,f)
    df = nan(size(f));

    for i =1:length(x);
        j1=i-1;
        j2=i+1;
        if i==1; j1=i+1; j2=i+2;end;
        if i==length(x); j1 = i-2; j2 =i-1;end;
        c1 = (f(j1)-f(i))./(x(j1)-x(i));
        c2 = (f(j2)-f(i))./(x(j2)-x(i));
        df(i) = (c1.*(x(j2)-x(i)) - c2.*(x(j1)-x(i)))./(x(j2)-x(j1));  
    end


end



