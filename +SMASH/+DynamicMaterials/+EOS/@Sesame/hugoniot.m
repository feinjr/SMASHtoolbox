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
% See also Sesame, hugoniotP, isentrope, isobar, isochor, isotherm
%

% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=hugoniot(varargin)

% Error checking

if (nargin<2) || isempty(varargin{2})
    error('Invalid input. Require at least (obj,density);');
end

object = varargin{1};
density = varargin{2};

if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

if max(density) > max(object.Density)
    warning('Density exceeds the maximum of the table, it will be clipped');
    trim = density <= max(object.Density);
    density = density(trim);
end


%Input initialization
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



%Lookup initial temperature and energy
if P0 < 1e-3
    T0 = 298.0;
else
    T0 = reverselookup(object,'Pressure',P0,rho0);
end
T0 = fzero(@(x) lookup(object,'Pressure',rho0,x)-P0,T0);

P0 = lookup(object,'Pressure',rho0,T0);
E0 = lookup(object,'Energy',rho0,T0);


%Quick guess based on 50 points spanning density range
dguess = linspace(density(1),density(end),50)';
tguess = PointHugSolve(object,dguess,rho0,P0,E0,T0);
tguess = interp1(dguess,tguess,density,'pchip',0);

%Newton-Raphson vector solution - generally fastest but need a reasonable
%first guess when Hugoniot is not smooth. If it's not converging, the
%pointwise solution is used.
temperature = NRHugSolve(object,density,rho0,P0,E0,tguess);

%Secant vector solution - convergence problems for some tests
%temperature = SecantHugSolve(object,density,rho0,P0,E0,tguess);

%Pointwise combination of fzero or Newton-Raphson. This is generally the
%most robust, but also takes the longest. Scales very poorly for more than
%1000 points
%temperature = PointHugSolve(object,density,rho0,P0,E0,tguess);




pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature);

%Find us and up.
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



%% Fzero / Newton-Raphson Hugoniot solution: pointwise
function temperature = PointHugSolve(object,density,rho0,P0,E0,Tguess)

%% Solve Rankine-Hugoniot jump conditions using fzero
tol=1e-4; 
options = optimset('TolX',tol);
temperature = nan(size(density));

temperature(1) = fzero(@(x) lookup(object,'Energy',density(1),x)-E0 ...
  -0.5.*(lookup(object,'Pressure',density(1),x)+P0).*(1/rho0-1/density(1)),Tguess(1),options);
 
 for i = 2:length(density);
     
     if length(Tguess) >=i
         tg = Tguess(i);
     else
         tg = temperature(i-1);
     end
     
     %If fzero fails
     try
         temperature(i) = fzero(@(x) lookup(object,'Energy',density(i),x)-E0 ...
          -0.5.*(lookup(object,'Pressure',density(i),x)+P0).*(1/rho0-1/density(i)),tg,options);
     
     %Use Newton-Raphson
     catch
        %warning('fzero failure, using Newton-Raphson');
        d = density(i);
        t = tg;
        mult = 1.0; iternum=100;

        [e,dedd,dedt] = lookup(object,'Energy',d,t);
        [p,dpdd,dpdt] = lookup(object,'Pressure',d,t);
        check = e-E0 - 0.5.*(p-P0).*(1/rho0-1/d);
        tnew = t;

        for iter=1:iternum
            if (tnew < 0)
                tnew = t*3/2;
            end
            if (tnew >= max(object.Temperature))
                warning('Temperature limit of table reached')
                range=tnew>=max(object.Temperature);
                tnew(range) = max(object.Temperature);
                break;
            end          
            t = tnew;
            [e,dedd,dedt] = lookup(object,'Energy',d,t);
            [p,dpdd,dpdt] = lookup(object,'Pressure',d,t);

            %Check new temperature
            check = e-E0 - 0.5.*(p-P0).*(1/rho0-1/d);
            if abs(check)<tol; break; end;

            %Newton-Raphson update if it hasn't converged
            tnew = t-mult.*(check./(dedt-0.5.*dpdt.*(1/rho0-1/d)));
        end

        if abs(check) > tol;
        warning('Warning: convergence not achieved for density = %f, energy tol = %f',d,check);
        end
        temperature(i) = tnew;
     end
         
     %update(w,i/length(density));
 end
end

% Newton-Raphson vector form solution
function temperature = NRHugSolve(object,d,rho0,P0,E0,Tguess)
tol=1e-4; iternum=50; mult=1.0; errold = 1e6*ones(size(d));
tnew = Tguess; tlimit=[];
for i=1:iternum   
    
    t = tnew;
    
    [e,dedd,dedt] = lookup(object,'Energy',d,t);
    [p,dpdd,dpdt] = lookup(object,'Pressure',d,t);

   
    %Check new temperature
    check = e-E0 - 0.5.*(p-P0).*(1./rho0-1./d);   
        
    %Newton-Raphson update if it hasn't converged
    tnew = t-mult.*(check./(dedt-0.5.*dpdt.*(1./rho0-1./d)));
    
    if any(tnew >= max(object.Temperature))
        warning('Hitting maximum temperature of table')
        tlimit = tnew >= max(object.Temperature);
        tnew(tlimit)=max(object.Temperature);
    end
    
    err = (tnew-t)./t;

    if (err < tol)
        temperature = tnew;
        return;
    end
    
    if (norm(err) > norm(errold))
         warning('Solution not converging, using fzero')
         temperature = PointHugSolve(object,d,rho0,P0,E0,Tguess);
         return;
    end
    errold=err;
end

warning('Warning: convergence not achieved, energy tol = %f',norm(err));
temperature = tnew;

end


 
 % %% Secant method - based on Kyle's 'hugd.pro'
function temperature = SecantHugSolve(object,d,rho0,P0,E0,Tguess)

%Find first temperature using fzero
tol = 1e-5;ratio=1.001;
options = optimset('TolX',tol);

    %Previous solution
    t0 = Tguess;
    p0 = lookup(object,'Pressure',d,t0);
    e0 = lookup(object,'Energy',d,t0);
    f0 = e0-E0+(P0+p0).*(1./rho0-1./d)*0.5;

    t1 = t0*ratio;
    p1 = lookup(object,'Pressure',d,t1);
    e1 = lookup(object,'Energy',d,t1);
    f1 = e1-E0+(P0+p1).*(1./rho0-1./d)*0.5;
    
    if abs(f0) < abs(f1)
        temp=t0; t0=t1; t1=temp;
        temp=f0; f0=f1; f1=temp;
        temp=e0; e0=e1; e1=temp;
        temp=p0; p0=p1; p1=temp;
    end


    for i=1:100
        
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
        
        t2 = t0-f0.*(t0-t1)./(f0-f1);
        err = (t2-t1)./t2;
        t0 = t1;
        t1 = t2;
        p0 = p1;
        e0 = e1;
        f0 = f1;
        
        plot(abs(err)); pause;
        if abs(err) < tol
            break;
        end
        
    end
    
    
    if abs(err) > tol;
        warning('Warning: convergence not achieved for density = %f, energy tol = %f',d,err);
    end
    temperature = t2;

end


