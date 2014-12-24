% MELT Calculate the melt curve
%
% This method returns the melt curve of the sesame object for the input 
% array of pressures and initial guess for the melt temperature.
%
%   Usage:
%    >> new=melt(object,pressure,T0);
%
% An isobar for each pressure is generated using a range of temperatues
% encompassing the melting point. The P-T discontinuity is found by
% examining it's derivative.
%
% Note: the algorithm is extremely slow, and possibly inaccurate. Use with
% caution.
%
% See also Sesame, hugoniot, isentrope, isobar, isochor, isotherm
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=melt(object,pressure,varargin)

% Error checking
if (nargin<2) || isempty(pressure)
    error('Invalid input. Require (object,pressure);');
end

if ~isnumeric(pressure) || min(size(pressure)) > 1
    error('Invalid format. Must enter numeric row or column vector for density');
end

T0 = 2500;
if nargin > 2
    T0 = varargin{1};
end



%Find first melt temperature based on initial guess
temperature = nan(size(pressure));
dmax = stp(object); 
dmax = dmax.Density;
dmin = min(object.Density);



dens = linspace(dmin,dmax,200)';
bar = isobar(object,dens,pressure(1));
[temperature(1),density(1),~] = findMelt(bar);

w = SMASH.MUI.Waitbar('Calculating Melt Curve');
for i = 2:length(pressure)
    
    while  (lookup(object,'Pressure',dmax,pressure(i)) < pressure(i))
        dmax = dmax*1.05;
    end
    
    if (lookup(object,'Pressure',dmax,pressure(i)) > pressure(i))
       dmax = dmax/1.02;
    end
    
    dens = linspace(density(i-1)*.95, dmax,200)';
    bar = isobar(object,dens,pressure(i));
    [temperature(i),density(i)] = findMelt(bar);
    update(w,i/length(pressure));
end
delete(w); 

pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature); 

new = SMASH.DynamicMaterials.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= 'Melt Curve';
new.Source = 'Calculated';
new.SourceFormat='melt';
end


% Find melt temperature along the isobar
% Algorithm fits gaussian to (dT/dV)|P to find the peak of transition. The
% FWHM/2 is subtracted to account for latent heat up to the peak
function [tmelt, dsol, dliq] = findMelt(obj)

    %Find guassian fit to dT/drho
    [~,ia] = unique(obj.Temperature);
    sig = SMASH.SignalAnalysis.Signal(obj.Temperature(ia),obj.Energy(ia)); 
    dsig = differentiate(sig); [x,y] = limit(dsig); y = abs(y);
    
    % remove slow trend
    p=polyfit(x,y,2);
    y=y-polyval(p,x); y = y-y(1)+obj.Energy(1);
    dsig = SMASH.SignalAnalysis.Signal(x,y);
    
    
%     %Use peak of de/dp
%     [~,im] = max(y);
%     tmelt = x(im);
%     tmeltsol = tmelt;
%     tmeltliq = tmeltsol;
    
    
    %Guassian fit
    report = locate(dsig,'step');
    dsig = crop(disg,[report.Location - 100, report.Location + 100]);
    %report = locate(dsig,'peak');
     
    %Plot quality of guassian fit
     plot(dsig.Grid,dsig.Data,dsig.Grid,report.Fit)
     pause;
     
    %Approximate solid density by subtracting half the FWHM
    tmeltsol = report.Location - 2*sqrt(2*log(2))*report.Width/2;
    tmeltliq = report.Location + 2*sqrt(2*log(2))*report.Width/2;

    indexsol = find(tmeltsol>=obj.Temperature, 1,'first');
    indexliq = find(tmeltliq>=obj.Temperature, 1,'first');
    tmelt = report.Location;
    dsol = obj.Density(indexsol);
    dliq = obj.Density(indexliq);

    
    %Plot calculated melt
    plot(obj.Temperature,obj.Density);  
    line([tmeltsol tmeltliq],[dsol dliq],'Color','r');
    xlabel('Temperature');
    ylabel('Density');
    legend({'isobar','melt'});
    
end



