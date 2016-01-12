% analyze: Analyze an nTOF object to determine the ion temperature
%
% This method analyzes the step wedge image to determine how
% measured optical density maps to film exposure.
%     >> object=analyze(object);
% Analysis must be performed before the apply method can be used.
%
% Step wedge analysis several intermediate steps.
%   -The user is prompted to crop the measurement (if not already done).
%   -Automatic rotation is applied to orient the measurement.
%   -Constant regions are identified by transitions of peak slope.
%   -Median values from each constant region are associated with total
%   optical density (step value plus offset)
% Analysis is controlled by various settings (derivative parameters, etc.).
%  These settings may be adjusted using the "configure" method.
%
% See also StepWedge, apply, configure, clean, crop, rotate
%

%
% created August 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=temperature(object,options)
%
p = object.Settings;

signalLims = p.SignalLimits;        %   Limits of entire signal of interest
noiseLims = p.NoiseLimits;         %   Limits to use for analyzing signal noise and baseline
fitLims = p.FitLimits;           %   Limits to use for fitting of signal
sigIdx = p.FitSignal;            %   index telling which signal to use for fitting

cfit = SMASH.CurveFit.Curve;
basis = @(p,t) propagatemodel( p(1), p(2) , t, options);
cfit = add(cfit,basis,[3.111e-6, 2],'lower',[3.1e-6, 0.5],'upper',[3.13e-6, 4],'scale',1.0,'fixscale',false);

if isnan(object.Settings.FitSignal)
    %do nothing
else
    good = SMASH.SignalAnalysis.Signal(object.Measurement.Grid,object.Measurement.Data(:,sigIdx)/min(object.Measurement.Data(:,sigIdx)));
    good = crop(good,signalLims);
    noise = crop(good,noiseLims);
    baseline = mean(noise.Data);
    sigma = std(noise.Data);
    
    fitData = crop(good ,fitLims);
    W = sigma./sqrt(fitData.Data-baseline+1);
    
    norm = max(sgolayfilt(fitData.Data-baseline,5,25));
    
    Data = [fitData.Grid, (fitData.Data-baseline)/norm, W];
    good = good-baseline;
    good = good/max(good.Data);
    
    t = linspace(signalLims(1),signalLims(2),1e4);
    cfit=fit(cfit,Data);
    object.Settings.BangTime = cfit.Parameter{1}(1);
    object.Settings.Fit = cfit;
end

% handle output
if nargout==0
    if isnan(object.Settings.FitSignal)
        
    else
        disp(cfit)
        figure
        set(gca,'YScale','lin')
        hold all
        plot(good.Grid,good.Data)
        plot(t,evaluate(cfit,t))
    end
else
    varargout{1}=object;
    if ~isnan(object.Settings.FitSignal)
        disp(cfit)
        figure
        set(gca,'YScale','lin')
        hold all
        plot(good.Grid,good.Data)
        plot(t,evaluate(cfit,t))
    end
end

end