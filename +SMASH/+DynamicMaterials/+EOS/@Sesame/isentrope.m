% ISENTROPE  Generate a curve of constant entropy from a sesame table object
%
% This method returns the new isentrope object for the input array
% of densities, initial density (rho0), initial temperatutre (T0), and 
% initial particle velocity up0. 
%
%    Usage:
%    >> new =isentrope(object,density)
%    >> new =isentrope(object,density,rho0,T0,up0)
%
% Care should be taken with the density array and initial values. An
% attempt is made to ensure consistency with the initial state but it is
% best if rho(1) = rho0. A compression should be an increasing density array 
% while a release should be decreasing. The step size for the integration 
% is the step between densities so this dictates the accuracy. Rho0 and up1 
% are only used to convert between Eulerian and Lagrangian soundspeeds, and 
% to define the initial particle velocity, respectively.
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

%Assume STP for rho0
st = stp(object,density(1)); 
rho0 = st.Density;
T0 = st.Temperature
P0=st.Pressure;
up1 = 0;

if nargin > 2
    rho0 = varargin{3};
    if rho0 > density(1)
        temp = rho > rho0;
        rho = rho(temp);
    end
end
if nargin > 3
    T0 = varargin{4};
end    
if nargin > 4
    up1 = varargin{5};
end  

if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format for density. Must enter numeric row or column vector');
end

%Lookup initial state
S0 = lookup(object,'Entropy',density(1),T0);
E0 = lookup(object,'Energy',density(1),T0);

%%
%If there is no entropy table then integrate PVT

if mean(isfinite(object.Entropy)) < 0.9
    disp('WARNING: Invalid entropy table detected, using thermodynamic integration');
    
    %Solve for isentrope from initial conditions
    temperature = IntPVT(object,density,T0);      
    pressure = lookup(object,'Pressure',density,temperature);
    energy = lookup(object,'Energy',density,temperature);
    entropy = lookup(object,'Entropy',density,temperature);   
else

    %Find temperatures along isentrope through reverse lookup. If there is a problem, use the PVT integration. 
    try
        temperature = reverselookup(object,'Entropy',repmat(S0,size(density)),density);
    catch
        temperature = T0.*ones(size(density));
    end
        pressure = lookup(object,'Pressure',density,temperature);
        energy = lookup(object,'Energy',density,temperature);
        entropy = lookup(object,'Entropy',density,temperature);

    % Check thermodynamic consistency: E = PdV
    if numel(density) > 1
        check = find(abs(1+(energy-energy(1))./cumtrapz(1./density,pressure)) > .01 & energy > max(energy)*.1);
        if check 
            disp('WARNING: thermodynamic inconsistency detected in reverse lookup, using integration instead');
            %figure; plot(density,energy,density,-cumtrapz(1./density,pressure)+energy(1))

            %Solve for isentrope
            temperature = IntPVT(object,density,T0);
            pressure = lookup(object,'Pressure',density,temperature);
            energy = lookup(object,'Energy',density,temperature);
            entropy = lookup(object,'Entropy',density,temperature); 
        end
    end

end
        
% %Calculate soundspeed
% cb = zeros(size(density)); up = cb;
% 
% if numel(density) > 1
%     %cb = diff(pressure)./diff(density); cb(end+1)=cb(end); cb = sqrt(cb); 
%     cb = quaddiff(density,pressure); 
%     cb = sqrt(abs(cb));
% end

%Calculate soundspeed
[e,dedr,dedt] = lookup(object,'Energy',density,temperature);
[p,dpdr,dpdt] = lookup(object,'Pressure',density,temperature);

if dpdr < 0
    temp = dpdr<0;
    warning('dP/dR reset to 0 as per Kerley EOS')
    dpdr(temp) = 0;
end

cb = sqrt(dpdr + (dpdt.*dpdt)./(density.*density)./dedt.*temperature);

%Compute particle velocities
if length(density)==1
    up = up1;
else
    up = up1 + cumtrapz(density,cb./density);
end

%Convert from Eulerian to Lagrangian
cb = cb.*density./rho0;

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
new.Data{1}=up;
new.Data{2}=cb;

%Set some properties
new.Name='Isentrope';
new.Source = 'Calculated';
new.SourceFormat='isentrope';



end


%Solves dt/dv|s = -T (dp/dt)|v / (de/dt)|v  
%For each density point, a fixed point iteration on T is performed using
%the derivatives from the lookup. A maximum of 10 iterations is performed
%before moving to the next density if 0.1% in T is  not achieved.
function temperature = IntPVT(object,density,T0)
    dsize = size(density);
    
    density = density(:);
    tol = 1e-4;
    %t = repmat(T0,size(density));
    Tend = density(end)./density(1).*T0;
    temperature = density.*(Tend-T0)./(density(end)-density(1));
    
    if density(end) > density(1);
        compression=1;
    else
        compression = 0;
    end
    
    for count = 1:10
        t = temperature;
        dpdt = zeros(size(t));
        dedt = zeros(size(t));
        
        % Lookup derivatives
        [~,~,dpdt] = lookup(object,'Pressure',density,temperature);
        [~,~,dedt] = lookup(object,'Energy',density,temperature);
        
        % Fixed point iteration on temperature
        %temperature = cumtrapz(1./density,-t.*dpdt./dedt)+T0;
        
        %Split density to integrate up or down 
%         Lower= find(density < rho0) ;
%         Upper= find(density >= rho0);
%         tLower = cumtrapz(1./flipud(density(Lower)),-flipud(t(Lower)).*flipud(dpdt(Lower))./flipud(dedt(Lower)))+T0;
%         tUpper = cumtrapz(1./density(Upper),-t(Upper).*dpdt(Upper)./dedt(Upper))+T0;
%         temperature(Lower)=flipud(tLower); temperature(Upper)=tUpper;
        

        temperature = cumtrapz(1./density,-t.*dpdt./dedt)+T0;
             
        check = sqrt(sum((temperature-t).^2))/length(temperature);
        if check < tol
            break
        end
        
        if count == 1
            %w = SMASH.MUI.Waitbar('Calculating Isentrope');
        elseif count > 1
            %update(w,count/10);
        end
    end
    

    temperature=reshape(temperature,dsize);
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




%%
% K. Cochran's compression_isentrope.pro
% Rold=density(1);
% T0 = reverselookup(object,'Pressure',P0,Rold);
% T0 = fzero(@(x) lookup(object,'Pressure',Rold,x)-P0,T0);
% Told=T0;
% 
% Pold = P0;
% 
% P=zeros(size(density));
% T=P;
% cb=P;
% 
% P(1)=P0;
% T(1)=Told;
% 
% for i = 2:length(density);
%     Rnew = density(i);
% 
%     %Calculate soundspeed
%     [e,dedr,dedt] = lookup(object,'Energy',Rold,Told);
%     [p,dpdr,dpdt] = lookup(object,'Pressure',Rold,Told);
% 
%     if dpdr < 0
%         warning('dP/dR reset to 0 as per Kerley EOS')
%         dpdr = 0;
%     end
% 
%     Cs2 = dpdr + (dpdt*dpdt)/(Rold*Rold)/dedt*Told;
% 
%     %Updates
%     Pnew = Cs2*(Rnew-Rold)+Pold;
% 
%     Told = reverselookup(object,'Pressure',Pnew,Rnew);
% 
%     if Told > 0
%         T(i)=Told;
%         P(i)=Pnew;
%         cb(i-1)=sqrt(Cs2);
%     end
% 
%     Pold = Pnew;
%     Rold = Rnew;
% 
% 
% end
% 
% [e,dedr,dedt] = lookup(object,'Energy',Rold,Told);
% [p,dpdr,dpdt] = lookup(object,'Pressure',Rold,Told);
% cb(i) = sqrt(dpdr + (dpdt*dpdt)/(Rold*Rold)/dedt);
% 
% 
% pressure = P;
% temperature = T;
% energy = lookup(object,'Energy',density,temperature);
% entropy = lookup(object,'Entropy',density,temperature);
% 
% %Compute particle velocities
% up = up1 + cumtrapz(density,cb./density);
% 
% %Convert from Eulerian to Lagrangian
% cb = cb.*density./rho0;
% 
% 
% new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);
% new.Data{1}=up;
% new.Data{2}=cb;
% 
% %Set some properties
% new.Name='Isentrope';
% new.Source = 'Calculated';
% new.SourceFormat='isentrope';
%%


