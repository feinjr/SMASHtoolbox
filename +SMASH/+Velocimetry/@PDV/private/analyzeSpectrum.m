function history=analyzeSpectrum(data,boundary,param,varargin)

data.FFToptions.FrequencyDomain='positive';
data.FFToptions.SpectrumType='power';

Nboundary=numel(boundary);

% analyze each boundary region
result=analyze(data,@processBlock);
    function parameter=processBlock(spectrum,local)
        parameter=nan(2,Nboundary);
        tmid=(local.Grid(end)+local.Grid(1))/2;
        for nn=1:Nboundary
            [fA,fB]=probe(boundary{nn},tmid);
            if isnan(fA)
                continue
            end
            temp=crop(spectrum,[fA fB]);
            [center,amplitude]=findPeak(temp.Grid,temp.Data,varargin{:});
            parameter(1,nn)=center;
            parameter(2,nn)=amplitude;
        end
        parameter=parameter(:);
    end

% estimate uncertainty
duration=data.Partition.Duration;
T=param.SampleInterval;
fs=1/T;

t=0:T:duration;
f0=fs/4;
s=cos(2*pi*f0*t);
temp=SMASH.SignalAnalysis.Signal(t,s);
[f,P]=fft(temp,data.FFToptions);
[~,amplitude]=findPeak(f,P,varargin{:});

% window correction...

table=result.Data;
if isempty(param.RMSnoise)
    table(:,2:2:end)=nan;
else
    table(:,2)=sqrt(table(:,2)/amplitude);
    table(:,2)=sqrt(6/(fs*duration^3))*param.RMSnoise./table(:,2)/pi;
end

t=result.Grid;
history=cell(Nboundary,1);
for n=1:Nboundary   
    keep=~isnan(table(:,1));
    history{n}=SMASH.SignalAnalysis.SignalGroup(t(keep),table(keep,1:2));
    table=table(:,3:end);         
end

end