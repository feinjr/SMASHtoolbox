% OPTIMIZE Optimizes the temperature of a Planck object to match 
% an input spectrum 
%
% This method calculates the optimal Planck spectrum that fits an input 
% spectrum:
%    >> object=optimize(object,[temperature]);
% with optional initial guess for temperature.
% The "new" object inherits most of its properties from the "old" object.
%
% See also Spectrum, Planck
%

% created April 9, 2014 by Tommy Ao (Sandia National Laboratories)
%
function object=optimize(object,varargin)

% verify uniform grid %
object=verifyGrid(object);
if object.GridUniform==false
    object=makeGridUniform(object);
end
x=object.Grid;
y=object.Data;

% handle input
if numel(varargin)>1
    temperature=max(varargin{2},1000);
else
    temperature=1000;
end

% inital preprations
amplitude=mean(y);
% normalize data
y=y/amplitude;

% perform nonlinear optimization
guess=temperature;
options=optimset('TolX',1e-6,'TolFun',1e-6);
fitness=@(NLparams) residual(NLparams,x,y);
[NLparams,~,~]=fminsearch(fitness,guess,options);
[~,params,yfit]=residual(NLparams,x,y);

% scale results
yfit=yfit*params(2);

% generate optimal Planck spectrum
object.Grid=x;
object.Data=yfit;
object.Temperature=params(1);
object.Emissivity=params(2)/amplitude;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual(NLparams,x,y)

% extract nonlinear least square parameters
temperature=abs(NLparams(1));
if (temperature<1000) || (temperature>1e9)
    chi2=inf;
    return
end

% Planck radiance
wavelength=x;
radiance=plancksLaw(wavelength,temperature);
amplitude=mean(radiance);
yfit=radiance/amplitude;

% calculate residual error
chi2=sum((y(:)-yfit).^2);
params=[temperature amplitude];

end