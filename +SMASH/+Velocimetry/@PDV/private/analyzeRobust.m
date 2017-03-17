function [result,extra]=analyzeRobust(data,boundary,noise)

% initial preparations
data.FFToptions.FrequencyDomain='positive';
data.FFToptions.SpectrumType='power';

% amplitude calibration
duration=data.Partition.Duration;
t=data.Measurement.Grid;
keep=(abs(t-min(t)) <= duration);
t=t(keep);
T=(max(t)-min(t))/(numel(t)-1);
fs=1/T;

f0=fs/4;
s=cos(2*pi*f0*t);
temp=SMASH.SignalAnalysis.Signal(t,s);
change=false;
while true
    [f,P]=fft(temp,data.FFToptions);
    [AmplitudeCalibration,minwidth,numpoints]=findPeak(f,P);
    if numpoints > 10
        break
    end  
    change=true;
    data.FFToptions.NumberFrequencies=2*data.FFToptions.NumberFrequencies;       
end
if change
    warning('SMASH:PDV',...
        'Increasing number of frequencies to %d for peak resolution',...
        data.FFToptions.NumberFrequencies(1));
end
AmplitudeCalibration=AmplitudeCalibration(2);
extra.NumberFrequencies=data.FFToptions.NumberFrequencies;

% 
noise=defineGrid(noise,t);

% analyze boundary regions
Nboundary=numel(boundary);
raw=analyze(data,@processBlock);
    function parameter=processBlock(spectrum,local)
        parameter=nan(3,Nboundary);
        tmid=(local.Grid(end)+local.Grid(1))/2;
        for nn=1:Nboundary
            % estimate peak location and density
            [fA,fB]=probe(boundary{nn},tmid);
            if isnan(fA)
                continue
            end
            center=(fA+fB)/2;
            left=min(fA,center-minwidth);
            right=max(fB,center+minwidth);
            temp=crop(spectrum,[left right]);
            value=findPeak(temp.Grid,temp.Data);
            % estimate artifact density
            noise=generate(noise);
            [f,P]=fft(noise.Measurement,data.FFToptions);
            keep=(f >= left) & (f <= right);
            artifact=findPeak(f(keep),P(keep));
            value(2)=value(2)-artifact(2);
            value(2)=max(value(2),0);
            value(3)=duration;
            parameter(:,nn)=value;
        end
        parameter=parameter(:);
    end

% estimate effective duration
switch data.FFToptions.Window
    case 'hann'
        duration=duration*(0.34/0.58);
    case 'hamming'
        duration=duration*(0.37/0.58);
end

% format results
t=raw.Grid;

result=cell(Nboundary,1);
index=[1 2 3];
for n=1:Nboundary
    temp=raw.Data(:,index);
    keep=~isnan(temp(:,1));
    temp=temp(keep,:); 
    temp(:,2)=sqrt(temp(:,2)/AmplitudeCalibration); % calibrated signal amplitude
    result{n}=SMASH.SignalAnalysis.SignalGroup(t(keep),temp);
    result{n}.Name=boundary{n}.Label;
    result{n}.GridLabel='Time';
    result{n}.Legend={'Frequency' 'Signal amplitude' 'Effective duration'};
    index=index+3;
end

end

function [result,varargout]=findPeak(x,y)

keep=true(size(x));
iteration=0;
while true
    iteration=iteration+1;
    xi=x(keep);
    yi=y(keep);
    area=trapz(xi,yi);
    wi=yi/area;
    center=trapz(xi,wi.*xi);
    width=sqrt(trapz(xi,wi.*(xi-center).^2));
    %fprintf('%d : %g %g\n',iteration,center,width);    
    minwidth=4*width;
    keep= (abs(x-center) < (minwidth));    
    if iteration==1
        previous=minwidth;
        continue
    elseif iteration > 10
        break
    else
        change=abs(1-minwidth/previous);
        if change < 1e-3;
            break
        end
        previous=minwidth;
    end
end

result=[center area/width];

if nargout >= 2
    varargout{1}=minwidth;
    varargout{2}=sum(keep);
end

end