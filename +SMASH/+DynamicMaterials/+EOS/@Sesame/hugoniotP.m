% HUGONIOTP Generate Hugoniot curve from sesame table object
%
% This method returns the new Hugoniot sesame object for a final pressure
% (PF), initial pressure (P0), initial density (rho0), and initial particle
% velocity, up1.
%
% Usage:
%    >> new=hugoniot(object,PF)
%    >> new=hugoniot(object,PF,P0,rho0,up1)
%    
% The initial conditions are used to interpolate for the initial energy,
% and then the secant method is used to solve for Hugoniot. Density and
% temperature steps are caculated internally. Uses K. Cochran's 'hugd.pro'
% algorithm.
%
% See also Sesame, isentrope, isobar, isochor, isotherm
%

% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=hugoniotP(varargin)

if (nargin<2) || isempty(varargin{2})
    error('Invalid input. Require at least (obj,PF);');
end

object = varargin{1};
PF = varargin{2};


%Input initialization
object = varargin{1};
PF = varargin{2};
P0 = 0;
rho0 = stp(object); rho0 = rho0.Density;
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

%Lookup initial temperature and energy
if P0 < 1e-3
    T0 = 298.0;
else
    T0 = reverselookup(object,'Pressure',P0,rho0);
end
T0 = fzero(@(x) lookup(object,'Pressure',rho0,x)-P0,T0);
E0 = lookup(object,'Energy',rho0,T0);


%w = SMASH.MUI.Waitbar('Calculating Hugniot Points');

%% Secant method - based on Kyle's 'hugd.pro'
ratio = 1.001; tol = 1e-12;

newd = rho0;
d=rho0*ratio;
t0 = T0;
irat=1;

Dh = rho0;
Ph = P0;
Eh = E0;
Th = T0;
  

while(lookup(object,'Pressure',newd(end),max(Th)) < PF & min(Th) > 1.0 & max(Th) < max(object.Temperature))
    
    p0 = lookup(object,'Pressure',d,t0);
    e0 = lookup(object,'Energy',d,t0);
    f0 = e0-E0+(P0+p0).*(1./rho0-1./d)*0.5;

    t1 = t0*ratio;
    if t1 > max(object.Temperature);
        t1=max(object.Temperature);
        break;
    end
    p1 = lookup(object,'Pressure',d,t1);
    e1 = lookup(object,'Energy',d,t1);
    f1 = e1-E0+(P0+p1).*(1./rho0-1./d)*0.5;
    
    %Swap if going wrong way
    if abs(f0) < abs(f1)
        temp=t0; t0=t1; t1=temp;
        temp=f0; f0=f1; f1=temp;
        temp=e0; e0=e1; e1=temp;
        temp=p0; p0=p1; p1=temp;
    end

    err = 1e6; cnt = 1;
    while (tol < abs(err) & cnt <= 1e3);
        
        if d > max(object.Density)
            warning('Reached maximum density of the table');
            d = max(object.Density);
        end
        
        if t1 > max(object.Temperature)
            warning('Reached maximum temperature of the table');
            t1 = max(object.Temperature);
        end
        
        p1 = lookup(object,'Pressure',d,t1);
        e1 = lookup(object,'Energy',d,t1);

        f1 = E0-e1+(p1+P0).*(1./rho0-1./d)*0.5;
        
        t2 = t0-f0*(t0-t1)/(f0-f1);
        err = (t2-t1)/t2;
        t0 = t1;
        t1 = t2;
        p0 = p1;
        e0 = e1;
        f0 = f1;
        cnt = cnt+1;
    end
    
    if t2 > max(Th)
        newd = [newd,d];
        Th = [Th,t2];
        d=max(newd)*ratio;
        t0=max(Th);
        irat=1;
    else
        d = max(newd)*(1+(ratio-1)*irat);
        t0=max(Th);
        t1=max(object.Temperature);
        irat=irat+1;
    end
    if irat==1000; break; end;
    
end
 
density = newd;
index = isfinite(newd);
density = density(index);
temperature = Th(index);
 

pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);


Us = sqrt(abs((pressure-P0)./(rho0-rho0^2./density)));
up = (pressure-P0)./(rho0.*Us)+up1;
temp = Us < 1e-3;
up(temp)=up1;
Us(temp)=pressure(temp)./(rho0*up(temp));


new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=up;
new.Data{2}=Us;

%Set some properties
new.Name='Hugoniot';
new.Source = 'Calculated';
new.SourceFormat='hugoniot';

end


