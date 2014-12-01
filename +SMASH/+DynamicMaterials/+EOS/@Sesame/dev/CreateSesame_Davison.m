function object=CreateSesame(object,varargin)
    
% This program creates a sesame object using an EOS model and reference
% curve. Currently, only a Mie-Gruneisen EOS based on either an isentrope
% or Hugoniot is supported.
%
%   >> object=CreateSesame('Mie-Gruniesen','pdisentrope',dref,pref,d0,g0,cv);
%
% populates a sesame table using a Mie-Gruneisen formulation (g0/v0 = g/v)
% based on a reference isentrope specified by density (dref) and pressure 
% (pref) arrays. Other valid options include 'cuIsentrope' (wavespeed-
% particle velocity based isentrope), 'usupHugoniot' (shock-particle
% velocity Hugoniot), and 'pdHugoniot (pressure-density Hugoniot).
%
% See also Sesame
%
% created April 24, 2014 by Justin Brown (Sandia National Labs)

numarg = nargin-1;
%Error checking
if (numarg<7) 
    error('Require at least model type, refx,refy, ref rho, g0, cv');
end

%Initial input variables
if (numarg>6)
    modtype = varargin{1};
    refcurve = varargin{2};
    refx = varargin{3};
    refy = varargin{4};
    d0 = varargin{5};
    g0 = varargin{6};
    cv = varargin{7};
    t0 = 298.15;
    nd = 300;
    nt = 100;
end
if (numarg>7) 
   t0 = varargin{8};
end
if (numarg>8) 
   nd = varargin{9};
end
if (numarg>9) 
   nt = varargin{10};
end

s0 = 0;
e0 = 0;
v0 = 1./d0;
gonv = g0.*d0;
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

%If pdhugoniot given, calculate the pdisentrope
if strcmpi(refcurve,'pdhugoniot');
    
    %Davison, Fundamentals of Shock Waves, P.118
    p0 = interp1(refx,refy,d0);
    v0 = 1./d0;
    v=1./refx;
    
    dpdvh = diff(refy)./diff(v);
    dpdvh(end+1)=dpdvh(end);
    kv = 0.5.*gonv.*refy+(1-0.5.*gonv.*(v0-v)).*dpdvh;
    xv = exp(gonv.*(v(1)-v));
    p = xv.*(p0+cumtrapz(v,kv./xv));
    refy = p;
    refcurve = 'pdisentrope';
   
end


switch lower(modtype)
    case 'mie-gruneisen'
        switch lower(refcurve)
            case 'pdisentrope'
                [~,ia] = unique(refx);
                dref = refx(ia);
                pref = refy(ia);
                
                vref = 1./dref;
                eref = -cumtrapz(vref,pref)+e0;
                tref = t0.*exp(gonv.*(v0-vref));

                %Create density and temperature grid points
                dgrid = logspace(log10(d0),log10(dref(end)),nd)';
                tgrid = logspace(log10(tmin),log10(10.*max(tref)),nt)';
                v=1./dgrid;
                prefgrid = interp1(dref,pref,dgrid,'pchip');
                erefgrid = interp1(dref,eref,dgrid,'pchip');
                
                %Calcualte thermodynamic values along grid, outer loop is
                %temperature
                density=[]; temperature=[];entropy = []; pressure=[]; energy=[];
                
                %Choose reference entropy so s > 0
                s0 = -cv.*log(tgrid(1)./(t0.*exp(gonv.*(v0-v(end)))));
                
                for j = 1:nt
                    densitynew = 1./v;
                    temperaturenew = tgrid(j).*ones(size(v));
                    
                    %Davison, Fundamentals of Shock Waves P.99
                    entropynew = s0 + cv.*log(tgrid(j)./(t0.*exp(gonv.*(v0-v))));
                    pressurenew = prefgrid+gonv.*cv.*t0.*exp(gonv.*(v0-v)).*(exp((entropynew-s0)./cv)-1);
                    energynew = erefgrid+cv.*t0.*exp(gonv.*(v0-v)).*(exp((entropynew-s0)./cv)-1);
                    
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
                
                
object = SMASH.EOS.Sesame(density,temperature,pressure,energy,entropy);                
object.Name='Custom Sesame';
object.Source = 'Reference Curve';
object.SourceFormat='sesame';
object=revealProperty(object,'SourceFormat');               
                

end
