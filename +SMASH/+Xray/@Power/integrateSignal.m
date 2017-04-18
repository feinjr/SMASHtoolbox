%
%
% created February 28, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%
function object = integrateSignal(object,varargin)
method = 'direct';
if nargin == 1
    SignalNumber = size(object.Settings,2)-1;
    Signals = 1:SignalNumber;
elseif numel(varargin) == 1
    Signals = varargin{1};
elseif numel(varargin) > 1
    for i = 1:numel(varargin)
        if i == 1
            Signals = varargin{i};
        end
        if strcmp(varargin{i},'Method')
            method = lower(varargin{i+1});
        end
    end
end

%% Integrate ZBL diode signal and normalize

SignalGrid = object.SourcePower.Grid;

for i=Signals
    SignalData = object.SourcePower.Data(:,i);
    
    IntegrationLimits = cell2mat(object.Settings{11,i+1});
    
    if IntegrationLimits(2)>IntegrationLimits(1)
        
        [~,SignalStartInd]=min(abs(IntegrationLimits(1)-SignalGrid(:,1)));
        
        [~,SignalEndInd]=min(abs(IntegrationLimits(2)-SignalGrid(:,1)));
        
        SignalCut = [SignalGrid(SignalStartInd:SignalEndInd) SignalData(SignalStartInd:SignalEndInd)];
        
        switch method
            case 'direct'
                InTrapzSignal = trapz(SignalCut(:,1),SignalCut(:,2));
            
            case 'fit'
                [peakVal, peakIdx] = max(SignalCut(:,2));
                tPeak = SignalCut(peakIdx,1);
                dx = SignalCut(2,1) - SignalCut(1,1);
                
                SignalFitStart = 1;
                SignalFitEnd = peakIdx + floor(0.5e-9/dx);
                
                SignalFit = [SignalCut(SignalFitStart:SignalFitEnd,1), SignalCut(SignalFitStart:SignalFitEnd,2)];
                guess = [tPeak, 1e-9];
                
                G=SMASH.CurveFit.makePeak('gaussian');
                cfit = SMASH.CurveFit.Curve;
                cfit = add(cfit, G, guess, 'lower', [tPeak-3e-9, 0.2e-9], 'upper', [tPeak+3e-9, 3.0e-9], 'scale',peakVal, 'fixscale',false);
                cfit = fit(cfit, SignalFit);
                x = linspace(SignalCut(1,1),SignalCut(end,1),1000);
                
                figure
                hold all
                plot(SignalCut(:,1),SignalCut(:,2))
                plot(x, evaluate(cfit,x))
                
                InTrapzSignal = trapz(x,evaluate(cfit,x));
        end
        %% Calculate energy absorbed by detector
        object.AnalysisSummary{9,i+1} = InTrapzSignal;
        GeometryCorrection = cell2mat(object.Settings(14,i+1));
        DistanceCorrection = cell2mat(object.Settings(15,i+1));
        ApertureCorrection = cell2mat(object.Settings(8,i+1))/cell2mat(object.Settings(9,i+1));
        CorrectionFactor = GeometryCorrection*DistanceCorrection*ApertureCorrection;
        
        DetectorEnergy = InTrapzSignal/CorrectionFactor;
        
        object.AnalysisSummary{7,i+1} = DetectorEnergy;
        
    else
        disp('Integration limits are not valid')
    end
    
end
end