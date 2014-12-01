function object=CreateSesame(object,varargin)
    
% This program creates a sesame object using an EOS model and reference
% curve. Currently, only a Mie-Gruneisen EOS based on either an isentrope
% or Hugoniot is supported.
%
%   >> object=CreateSesame('Mie-Gruniesen','pdisentrope',dref,pref,d0,g0,L,cv);
%
% populates a sesame table using a Mie-Gruneisen formulation (g0/v0^L = g/v^L)
% based on a reference isentrope specified by density (dref) and pressure 
% (pref) arrays. Other valid options include 'cuIsentrope' (wavespeed-
% particle velocity based isentrope), 'usupHugoniot' (shock-particle
% velocity Hugoniot), 'pdHugoniot (pressure-density Hugoniot), and
% 'pdIsotherm' (pressure-density isotherm).
%
%   Additional optional input variables are T0, TMAX, nd, nt. By default
%   TMIN is set to 250K. TMAX, nd, and nt are set to 10000K, 300, and 100.
%
% See also Sesame
%
% created April 24, 2014 by Justin Brown (Sandia National Labs)

numarg = nargin-1;
%Error checking
if (numarg<=7) 
    error('Require at least model type, ref curve type, refx,refy, ref rho, g0, L, cv');
end

%Initial input variables
if (numarg>7)
    modtype = varargin{1};
    refcurve = varargin{2};
    refx = varargin{3};
    refy = varargin{4};
    d0 = varargin{5};
    g0 = varargin{6};
    L = varargin{7};
    cv = varargin{8};
    t0 = 298.15;
    tmax = 1.0e4;
    nd = 300;
    nt = 100;
end
if (numarg>8) 
   t0 = varargin{9};
end
if (numarg>9) 
   tmax = varargin{10};
end
if (numarg>10) 
   nd = varargin{11};
end
if (numarg>11) 
   nt = varargin{12};
end

v0 = 1./d0;
tmin = 250;

%If wavespeeds given, integrate to find stress, density
if strcmpi(refcurve,'cuisentrope');
    %Integrate conservation equation
    stress = d0.*cumtrapz(refx,refy);
    strain = cumtrapz(refx,1./refy);
    refx = d0./(1-strain);
    refy = stress;
    refcurve = 'pdisentrope';
end

%If usup given, calculate stress, density Hugoniot
if strcmpi(refcurve,'usup');
    %Integrate conservation equation
    stress = d0.*refx.*refy;
    strain = refx./refy;
    refx = d0./(1-strain);
    refy = stress;
    refcurve = 'pdhugoniot';
end

switch lower(modtype)
    case 'mie-gruneisen'
        switch lower(refcurve)
            case 'pdisentrope'
                [~,ia] = unique(refx);
                dref = refx(ia);
                pref = refy(ia);

                vref = 1./dref;
                %eref = -cumtrapz(vref,pref)+e0;

                %Create density and temperature grid points
                dgrid = logspace(log10(d0),log10(dref(end)),nd)';
                tgrid = logspace(log10(tmin),log10(10.*max(tmax)),nt)';
                v=1./dgrid;
                prefgrid = interp1(dref,pref,dgrid,'pchip');
                %erefgrid = interp1(dref,eref,dgrid,'pchip');
                
                %Calcualte thermodynamic values along grid, outer loop is
                %temperature
                density=[]; temperature=[];entropy = []; pressure=[]; energy=[];
                
                for j = 1:nt
                    densitynew = 1./v;
                    temperaturenew = tgrid(j).*ones(size(v));
                    
                    %Principal isochor for inital pressures
                    pinit = g0/v0.*cv.*(tgrid(j)-t0);

                    %Solve ode for p(v)
                    [vsol, psol] = ode45(@(vo,po) isentrope_ode(vo,po,v,v0,prefgrid,temperaturenew,g0,L,cv),[v(1) v(end)],pinit);

                    %Interpolate solution back to desired grid
                    pressurenew = interp1(vsol,psol,v);
                    
                    %Solve for energy and entropy. Note: T=1 taken as absolute 0 reference                                 
                    dedv = cv.*temperaturenew.*g0.*v.^(L-1)./(v0.^L) - pressurenew;
                    energynew = cv*(temperaturenew-1) + cumtrapz(v,dedv);
                    
                    dsdv = cv.*g0.*v.^(L-1)./(v0.^L);
                    entropynew = cv.*log(temperaturenew./1)+cumtrapz(v,dsdv);
                                   
                    density = [density;densitynew];
                    temperature = [temperature;temperaturenew];
                    entropy = [entropy;entropynew];
                    pressure = [pressure;pressurenew];
                    energy = [energy;energynew];        
                end 
            
            case 'pdhugoniot'
                [~,ia] = unique(refx);
                dref = refx(ia);
                pref = refy(ia);
                
                vref = 1./dref;

                %Create density and temperature grid points
                dgrid = logspace(log10(d0),log10(dref(end)),nd)';
                tgrid = logspace(log10(tmin),log10(10.*max(tmax)),nt)';
                v=1./dgrid;
                prefgrid = interp1(dref,pref,dgrid,'pchip');
                
                %Calcualte thermodynamic values along grid, outer loop is
                %temperature
                density=[]; temperature=[];entropy = []; pressure=[]; energy=[];
                
                for j = 1:nt
                    densitynew = 1./v;
                    temperaturenew = tgrid(j).*ones(size(v));
                    
                    %Principal isochor for inital pressures
                    pinit = g0/v0.*cv.*(tgrid(j)-t0);
                    
                    %Solve ode for p(v)
                    [vsol, psol] = ode45(@(vo,po) hugoniot_ode(vo,po,v,v0,prefgrid,temperaturenew,g0,L,cv),[v(1) v(end)],pinit);

                    %Interpolate solution back to desired grid
                    pressurenew = interp1(vsol,psol,v);
                    
                    %Solve for energy and entropy. Note: ln(1) taken as absolute 0 reference                                 
                    dedv = cv.*temperaturenew.*g0.*v.^(L-1)./(v0.^L) - pressurenew;
                    energynew = cv*(temperaturenew-1) + cumtrapz(v,dedv);
                    
                    dsdv = cv.*g0.*v.^(L-1)./(v0.^L);
                    entropynew = cv.*log(temperaturenew./1)+cumtrapz(v,dsdv);
                                   
                    density = [density;densitynew];
                    temperature = [temperature;temperaturenew];
                    entropy = [entropy;entropynew];
                    pressure = [pressure;pressurenew];
                    energy = [energy;energynew]; 
                end
                
            case 'pdIsotherm'
                
                [~,ia] = unique(refx);
                dref = refx(ia);
                pref = refy(ia);
                
                vref = 1./dref;

                %Create density and temperature grid points
                dgrid = logspace(log10(d0),log10(dref(end)),nd)';
                tgrid = logspace(log10(tmin),log10(10.*max(tmax)),nt)';
                v=1./dgrid;
                prefgrid = interp1(dref,pref,dgrid,'pchip');
                
                %Calcualte thermodynamic values along grid, outer loop is
                %temperature
                density=[]; temperature=[];entropy = []; pressure=[]; energy=[];
                
                for j = 1:nt
                    densitynew = 1./v;
                    temperaturenew = tgrid(j).*ones(size(v));
                 
                    %Solve ode for p(v)
                    pressurenew = prefgrid + g0.*v.^(L-1)./(v0.^L).*cv.*(temperaturenew - t0);
             
                    %Solve for energy and entropy. Note: ln(1) taken as absolute 0 reference                                 
                    dedv = cv.*temperaturenew.*g0.*v.^(L-1)./(v0.^L) - pressurenew;
                    energynew = cv*(temperaturenew-1) + cumtrapz(v,dedv);
                    
                    dsdv = cv.*g0.*v.^(L-1)./(v0.^L);
                    entropynew = cv.*log(temperaturenew./1)+cumtrapz(v,dsdv);
                                   
                    density = [density;densitynew];
                    temperature = [temperature;temperaturenew];
                    entropy = [entropy;entropynew];
                    pressure = [pressure;pressurenew];
                    energy = [energy;energynew]; 
                end
                               
            otherwise
                error('Reference curve type not supported');
        end
    otherwise
        error('EOS model type not supported');
end
                
                
object = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);                
object.Name='Custom Sesame';
object.Source = 'Reference Curve';
object.SourceFormat='sesame';
object=revealProperty(object,'SourceFormat');               
                

end

%Function performs a quadratic differentiation of f(x). Consistent with
%Kerley's use.

function df = quaddiff(x,f)
    df = repmat(nan,size(f));

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


function dpdv = isentrope_ode(v,p,vnew,v0,pref,tnew,g0,L,cv)

%Interpolate vnew, pref, and tnew to solution "timebase": v
dprefdv = quaddiff(vnew,pref);
dprefdv = interp1(vnew,dprefdv,v);
pref = interp1(vnew,pref,v);
tnew = interp1(vnew,tnew,v);

dpdv = dprefdv+(((g0.*v.^(L-1))./(v0.^L)).^2).*cv.*tnew+((L-1)./v-g0.*v.^(L-1)./(v0.^L)).*(p-pref);

end

function dpdv = hugoniot_ode(v,p,vnew,v0,pref,tnew,g0,L,cv)

%Interpolate vnew, pref, and tnew to solution "timebase": v
dprefdv = quaddiff(vnew,pref);
dprefdv = interp1(vnew,dprefdv,v);
pref = interp1(vnew,pref,v);
tnew = interp1(vnew,tnew,v);

dpdvs = (1-0.5*g0.*((v/v0).^(L-1)).*(1-v./v0)).*dprefdv+(g0+2).*pref./(2.*v)-(g0+1).*p./v;
dpdv = dpdvs+cv.*tnew.*((g0.*v.^(L-1))./v0.^L).^2;

end

