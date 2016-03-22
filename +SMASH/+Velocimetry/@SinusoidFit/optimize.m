function object=optimize(object)

% manage input

% extract boundary
bound=object.FrequencyBound;
if isempty(bound)
    temp=SMASH.SignalAnalysis.Signal(object.Time,object.Signal);
    [f,P]=fft(temp,'Window','Hann',...
        'RemoveDC',true,'NumberFrequencies',10e3);
    P(P < 0.10*max(P))=0;
    weight=P/trapz(f,P);
    f0=trapz(f,f.*weight);
    width=sqrt(trapz(f,(f-f0).^2.*weight));
    data=nan(2,3);
    data(1,1)=min(object.Time);
    data(2,1)=max(object.Time);
    data(:,2)=f0;
    data(:,3)=width;
    bound=SMASH.ROI.BoundingCurve('horizontal');
    bound=define(bound,data);
    bound={bound};
end

% set up optimization
M=numel(bound);
guess=[];
Nm=nan(1,M);
for m=1:M
    [Delta,b,c]=...
        setupDomain(bound,object.Time,object.BreakTolerance);
    Nm(m)=numel(Delta{m});
    guess=[param; Delta(:); b(:); c(:)];
end

    function chi2=residual(param)
    end


end