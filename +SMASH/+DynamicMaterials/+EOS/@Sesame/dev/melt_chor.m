% MELT Calculate the melt curve
%
% This method returns the melt curve of the sesame object for the input 
% array of densities and initial guess for the melt temperature.
%
%   Usage:
%    >> new=melt(object,density,T0);
%
% An isochor for each density is generated using a range of temperatues
% encompassing the melting point. The P-T discontinuity is found by
% examining it's derivative.
%
% Note: the algorithm is extremely slow, and possibly inaccurate. Use with
% caution.
%
% See also Sesame, hugoniot, isentrope, isobar, isochor, isotherm
%
% created April 21, 2014 by Justin Brown (Sandia National Laboratories)

function new=melt(object,density,varargin)

% Error checking
if (nargin<2) || isempty(density)
    error('Invalid input. Require (object,density);');
end

if ~isnumeric(density) || min(size(density)) > 1
    error('Invalid format. Must enter numeric row or column vector for density');
end

T0 = 2500;
if nargin > 2
    T0 = varargin{1};
end

w = SMASH.MUI.Waitbar('Calculating Melt Curve');

%Find first melt temperature based on initial guess
temperature = nan(size(density));
t = linspace(T0/4,T0*4,100)';
chor = isochor(object,t,density(1));
[temperature(1),~,~] = findMelt(chor);

for i = 2:length(density)
    t = linspace(temperature(i-1)/2, temperature(i-1)*2,1000)';
    chor = isochor(object,t,density(i))
    [temperature(i),~,~] = findMelt(chor);
    update(w,i/length(density));
end
delete(w); 

pressure = lookup(object,'Pressure',density,temperature);
energy = lookup(object,'Energy',density,temperature);
entropy = lookup(object,'Entropy',density,temperature); 

new = SMASH.EOS.Sesame(density,temperature,pressure,energy,entropy);

%Set some properties
new.Name= 'Melt Curve';
new.Source = 'Calculated';
new.SourceFormat='melt';
end


% Find melt temperature along the isobar
% Algorithm fits gaussian to (dT/dV)|P to find the peak of transition. The
% FWHM/2 is subtracted to account for latent heat up to the peak
function [tmelt, psol, pliq] = findMelt(obj)

    % remove slow trend
    %p=polyfit(obj.Temperature,obj.Energy,1);
    %y=obj.Energy-polyval(p,obj.Temperature); y = y-y(1)+obj.Energy(1);
    y =obj.Pressure;

    %Find guassian fit to dT/drho
    sig = SMASH.SignalAnalysis.Signal(obj.Temperature,y); 
    dsig = differentiate(sig); [x,y] = limit(dsig);
    dsig = SMASH.SignalAnalysis.Signal(x,abs(y));
    report = locate(dsig);
    
    %Plot quality of guassian fit
    %plot(dsig.Grid,dsig.Data,dsig.Grid,report.Fit)
    %d2sig = differentiate(dsig);
    %plot(d2sig.Grid,d2sig.Data)
    %pause;
    
    %Approximate solid density by subtracting half the FWHM
    tmeltsol = report.Location - 2*sqrt(2*log(2))*report.Width/2;
    tmeltliq = report.Location + 2*sqrt(2*log(2))*report.Width/2;
    indexsol = find(tmeltsol<=obj.Temperature, 1);
    indexliq = find(tmeltliq<=obj.Temperature, 1);
    tmelt = report.Location;
    psol = obj.Pressure(indexsol);
    pliq = obj.Pressure(indexliq);
    
    %Plot calculated melt
    plot(obj.Temperature,obj.Pressure);  
    line([tmeltsol tmeltliq],[psol pliq],'Color','r');
    xlabel('Temperature');
    ylabel('Pressure');
    legend({'isochor','melt'});
    %pause;
end



