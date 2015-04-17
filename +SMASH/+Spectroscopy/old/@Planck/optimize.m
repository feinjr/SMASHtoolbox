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
% revised April 14, 2015 by Daniel Dolan
%   -enabled relative/absolute optimization
function object=optimize(object,mode)

% verify uniform grid %
object=verifyGrid(object);
if object.GridUniform==false
    object=makeGridUniform(object);
end
%x=object.Grid;
%y=object.Data;

if (nargin<2) || isempty(mode)
    mode='relative';
end
assert(strcmpi(mode,'relative') || strcmpi(mode,'absolute'),...
    'ERROR: invalid mode');

% inital preprations
%amplitude=mean(y);
% normalize data
%y=y/amplitude;
x=object.Grid; % wavelength
dLdx=object.Data; % spectral radiance

% perform nonlinear optimization
%guess=temperature;
options=optimset('TolX',1e-6,'TolFun',1e-6);
%fitness=@(NLparams) residual(NLparams,x,y);
Tguess=object.Temperature;
[NLparams,~,~]=fminsearch(@residual,sqrt(Tguess),options);
    function [chi2,fit,param]=residual(param)       
        T=param(1)^2; % enforce positive temperature
        radiance=plancksLaw(x,T,1);
        switch mode            
            case 'relative'
                amplitude=radiance(:)\dLdx(:);
                fit=amplitude*dLdx(:);
                emissivity=NaN;
            case 'absolute'
                emissivity=object.Emissivity;
                fit=emissivity*radiance;
        end                   
        param(end+1)=emissivity;        
        % calculate residual error
        chi2=mean((dLdx(:)-fit(:)).^2);        
    end
[~,fit,param]=residual(NLparams);

% generate optimal Planck spectrum
object.Grid=x;
object.Data=fit;
object.Temperature=param(1);
object.Emissivity=param(2);

end