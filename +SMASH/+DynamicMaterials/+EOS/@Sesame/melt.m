% MELT Calculate the melt curve
%
% This method returns the melt curve of the sesame object for the input 
% array of densities and initial guess for the melt temperature.
%
%   Usage:
%    >> new=melt(object,density,temperature,nsmooth);
%
% An isochor for each density is generated using the range of temperatures. 
% The P-T discontinuity is found by examining it's second derivative. If
% the temperature array is not specified, the grid points are used. Nsmooth
% relates to a bandpass filter to smooth numerical issues near the melt
% transition. Higher values represent a higher frequency filter, and a
% default of 15 is used if not specified.
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

t=unique(object.Temperature);
nsmooth = 15;
if nargin > 2
    if ~isempty(varargin{1})
        t = varargin{1};
    end
end
if nargin > 3
    nsmooth = varargin{2};
end

w = SMASH.MUI.Waitbar('Calculating Melt Curve');
temperature = nan(size(density));

%Find first melt temperature based on step in isochor
for i = 1:length(density)
    chor = isochor(object,t,density(i));
    [temperature(i),~,~] = findMelt(chor,nsmooth);
    update(w,i/length(density));
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
function [tmelt, psol, pliq] = findMelt(obj,nsmooth)

    x = obj.Temperature;
    y = obj.Pressure;
    
    sig = SMASH.SignalAnalysis.Signal(x,y);
    dsig = differentiate(sig);
    dsig = differentiate(dsig);
    dsig=dsig.^2;
   
    %Smooth derivative
    Nsmooth=int32(length(x)./nsmooth); %LowPassFilt
    kernel = ones(Nsmooth,1);
    kernel = kernel/sum(kernel);
    dsig=smooth(dsig,'kernel',kernel);
    
%     %Remove slow trend
%     [dx,dy]=limit(dsig);
%     trim = int32(length(dx)*.1);
%     dx = dx(trim:end-trim); dy = dy(trim:end-trim);
%     p=polyfit(dx,dy,1);
%     dy = dy-polyval(p,dx);
%     dsig = SMASH.SignalAnalysis.Signal(dx,dy);
    
    %Find peak
    report = locate(dsig,'peak');

    %Plot quality of guassian fit
    %plot(dsig.Grid,dsig.Data,dsig.Grid,report.Fit)
    %pause;
    
    %Approximate solid density by subtracting half the FWHM
    tmeltsol = report.Location - report.Width/2;
    tmeltliq = report.Location + report.Width/2;
    indexsol = find(tmeltsol<=obj.Temperature, 1);
    indexliq = find(tmeltliq<=obj.Temperature, 1);
    psol = obj.Pressure(indexsol);
    pliq = obj.Pressure(indexliq);
    tmelt=report.Location;

    %Plot calculated melt
    plot(obj.Temperature,obj.Pressure);  
    line([tmeltsol tmeltliq],[psol pliq],'Color','r');
    line([tmelt tmelt],[min(obj.Pressure) max(obj.Pressure)],'Color','m');
    xlabel('Temperature');
    ylabel('Pressure');
    legend({'isochor','melt'});
    %pause;
end



