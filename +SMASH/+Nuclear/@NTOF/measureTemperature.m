% analyze: Analyze an nTOF object to determine the ion temperature
%
% This method analyzes the nTOF object to determine an ion temperature.  A
% candidate neutron spectrum is generated using a suitable model.  This is
% propagated through the nTOF instrument model and compared to the data in
% the nTOF object.  Currently, the neutron spectrum is calculated using the
% Ballabio analytic formula (see propagatemodel.m for reference).  We plan
% to support other models in the future.
%
% Planned improvements:
%       Enhanced fitting options and statistics
%       Baseline options (flat, polynomial, exponential, double exp., etc)
%       Scattering and shielding models
%       Bias dependent throughput delays
%       Using different models to calculate spectrum (e.g. monteburns)
%
% created January 18, 2016 by Patrick Knapp (Sandia National Laboratories)
%
function varargout=measureTemperature(object,InitialGuess)
%
p = object.Settings;

signalLims = p.SignalLimits;        %   Limits of entire signal of interest
noiseLims = p.NoiseLimits;         %   Limits to use for analyzing signal noise and baseline
fitLims = p.FitLimits;           %   Limits to use for fitting of signal
sigIdx = p.FitSignal;            %   index telling which signal to use for fitting

options = struct(   'InstrumentResponse',   p.InstrumentResponse,...
                    'LightOutput',          p.LightOutput,...
                    'BurnWidth',            p.BurnWidth,...
                    'Earray',               p.Earray,...
                    'Reaction',             p.Reaction,...
                    'Location',             p.Location,...
                    'Distance',             p.Distance,...
                    'SignalLimits',         signalLims...
                    );                
cfit = SMASH.CurveFit.Curve;
basis = @(p,t) propagatemodel( p(1), p(2) , t, options);
cfit = add(cfit,basis,InitialGuess,'lower',[3.05e-6, 0.5],'upper',[3.13e-6, 6],'scale',1.0,'fixscale',false);

if isempty(object.Settings.FitSignal)
    %do nothing
else
    good = SMASH.SignalAnalysis.Signal(object.Measurement.Grid,object.Measurement.Data(:,sigIdx)/min(object.Measurement.Data(:,sigIdx)));
    good = crop(good,signalLims);
    noise = crop(good,noiseLims);
    baseline = mean(noise.Data);
    sigma = std(noise.Data);
    
    fitData = crop(good ,fitLims);
    W = sigma./sqrt(fitData.Data-baseline+1);
    
    fitData = smooth(fitData,'mean',5);
    norm = max(fitData.Data-baseline);
    
    Data = [fitData.Grid, (fitData.Data-baseline)/norm, W];
    good = good-baseline;
    good = good/norm;
    
    t = linspace(signalLims(1),signalLims(2),1e4);
    cfit=fit(cfit,Data);
    object.Settings.BangTime = cfit.Parameter{1}(1);
    object.Settings.Fit = cfit;
    object.Settings.FinalSignal = good;
end

% handle output
if nargout==0
    if isnan(object.Settings.FitSignal)
        
    else
        fprintf('Ion Temperature = %f keV\n',cfit.Parameter{1}(2))
        fprintf('Bang time = %f ns\n\n',1e9*cfit.Parameter{1}(1))
        figure
        set(gca,'YScale','lin')
        hold all
        plot(good.Grid,good.Data)
        plot(t,evaluate(cfit,t))
    end
else
    varargout{1}=object;
    if ~isnan(object.Settings.FitSignal)
        fprintf('Ion Temperature = %f keV\n',cfit.Parameter{1}(2))
        fprintf('Bang time = %f ns\n\n',1e9*cfit.Parameter{1}(1))
    end
end

end