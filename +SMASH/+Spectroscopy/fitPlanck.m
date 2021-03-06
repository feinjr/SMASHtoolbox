% fitPlanck Fit measurement with a Planck curve to determine temperature
%
% This function matches Planck emission with a spectroscopic measurement,
% resulting in an estimate of emitter temperature.  The basic calling
% sequence is:
%     >> [T,fit,scale]=fitPlanck(wavelength,radiance,guess);
% where wavelength is in nanometers and (spectral) radiance is in watts per
% square meter per steradian per nanometer.  A guess temperature must be
% provided to initiated the optimization; this temperature and the output
% are in Kelvin.  These three inputs are mandatory, while the additional
% inputs described below are optional and can specified in any order.
%
% The default optimization assumes perfect emissivity at all wavelengths.
% Different emissivities can be specified manaully.
%     >> [...]=fitPlanck(...,'Emissivity',value);
% Emissivities can be scalars, arrays (consistent with the wavelength
% input), or function handles.
%
% Measurements that are proportional to spectral radiance can be analyzed
% in a relative manner.
%     >> [...]=fitPlanck(wavelength,measurement,guess,'Mode','relative');
% Absolute analysis can be specified explicitly:
%     >> [...]=fitPlanck(...,'Mode','absolute');
% but doing so is not necessary.  For constant emissivity, relative
% analysis *may* perform better than absolute analysis, particularly when
% peak emission occurs at longer wavelengths than the measurement. Relative
% analysis becomes less useful at higher temperatures, where the emission
% peak occurs at shorter wavelengths than the measurement.  Custom
% emissivity can be applied to both analysis method; note that constant
% emissivity have no impact on relative analysis.
%
% Optimization can be restricted to a finite temperature range.
%     >> [...]=fitPlanck(...,'Bound',[Tmin Tmax]);
% The default range is ~2e-16 to infinity.  The second entry must be
% greater than the first, and both numbers must be positive.  The guess
% temperature must always fall inside the specified bounds.
%
% Weighting can be specified to preferentially fit portions of the
% measurement over less reliable regions.
%     >> [...]=fitPlanck(...'Weight',array);
% The weight array must be consistent with the wavelength and measurement
% inputs.  Weights are normalized internally.
%
% General optimization controls (number of iterations, etc.) can be
% controlled by passing an options structure.
%     >> [...]=fitPlanck(...,'Options',options);
% For more information, refer to the optimset function.
%
% If no outputs are specified, results are plotted to a new figure window.
%
% See also Spectroscopy, generatePlanck, optimset
%

%
%
%
function varargout=fitPlanck(wavelength,measurement,guess,varargin)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

assert(isnumeric(wavelength),'ERROR: invalid wavelength input');
assert(isnumeric(measurement),'ERROR: invalid measurement input');
assert(numel(wavelength)==numel(measurement),...
    'ERROR: inconsisent wavelength/measurement');
x=wavelength(:);
y=measurement(:);
KeepIndex = isnan(y)|isnan(x);
KeepIndex = ~KeepIndex;
x = x(KeepIndex);
y = y(KeepIndex);

assert(isnumeric(guess) & isscalar(guess) & guess>0,...
    'ERROR: invalid guess temperature');

setting=struct();
setting.Bound=[eps inf];
setting.Emissivity=ones(size(x));
setting.Options=optimset;
setting.Mode='absolute';
setting.Weight=ones(size(y));
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    switch lower(name)
        case 'bound'
            assert(isnumeric(value) & numel(value)==2 & (diff(value)>0),...
                'ERROR: invalid Bound values');
            setting.Bound=value;
        case 'emissivity'
            try % verify emissivity using generate function
                [~]=SMASH.Spectroscopy.generatePlanck(wavelength,1000,value);
                setting.Emissivity=value;
            catch
                error('ERROR: invalid Emissivity value(s)');
            end
        case 'options'
            try
                value=optimset(value);
                setting.Options=value;
            catch
                error('ERROR: invalid Options value');
            end
        case 'mode'
            assert(ischar(value),'ERROR: invalid Mode value');
            switch lower(value)
                case {'absolute','relative'}
                    setting.Mode=lower(value);
                otherwise
                      error('ERROR: invalid Mode value');  
            end
        case 'weight'
            value=value(:);
            value=value(KeepIndex);
            assert(isnumeric(value) & (numel(value)==numel(x)),...
                'ERROR: inconsistent measurement/weight arrays');
            setting.Weight=value;
        otherwise
            error('ERROR: %s is an invalid setting',name);
    end
end

assert((guess>=setting.Bound(1)) & (guess<=setting.Bound(2)),...
    'ERROR: guess temeprature outside of Bound setting');

% manage bound with parameter conversion function (q to T)
if isinf(setting.Bound(2))
    convert=@(q) setting.Bound(1)+q.^2; %
    guess=sqrt(guess-setting.Bound(1));
else
    baseline=sum(setting.Bound)/2;
    amplitude=diff(setting.Bound)/2;
    convert=@(q) baseline+amplitude*sin(q);
    guess=asin((guess-baseline)/amplitude);
end

% perform optimization
weight=setting.Weight/sum(setting.Weight);
q=fminsearch(@residual,guess,setting.Options);
    function [chi2,fit,T,scale]=residual(q)
        T=convert(q);
        dLdx=SMASH.Spectroscopy.generatePlanck(x,T,setting.Emissivity);
        switch setting.Mode
            case 'absolute'
                fit=dLdx;
                scale=nan;
            case 'relative'
                scale=dLdx\y;            
                %scale=y\dLdx;
                fit=scale*dLdx;
        end
        chi2=sum(weight.*(y-fit).^2);
%         if isnan(chi2)
%             keyboard;
%         end
    end
[~,fit,temperature,scale]=residual(q);

% manage output
if nargout==0
    figure;
    plot(x,y,'o',x,fit);
    xlabel('Wavelength (nm)');
    ylabel('Measurement');
    label=sprintf('Temperature=%.0f K, scale=%g',temperature,scale);
    title(label);
else
    varargout{1}=temperature;
    varargout{2}=fit;
    varargout{3}=1./scale;
end

end