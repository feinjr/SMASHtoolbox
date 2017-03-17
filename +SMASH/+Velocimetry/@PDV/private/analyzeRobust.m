function [result,extra]=analyzeRobust(data,boundary)

% initial preparations
data.FFToptions.FrequencyDomain='positive';
data.FFToptions.SpectrumType='power';
data.FFToptions.Normalization='none';

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

% noise calibration
temp=SMASH.SignalAnalysis.NoiseSignal(temp.Grid);
temp=defineTransfer(temp,'Bandwidth',f0);
NoiseCal=nan(10000,1);
for iteration=1:numel(NoiseCal);
    temp=generate(temp);
    [f,P]=fft(temp.Measurement,data.FFToptions);
    keep=(f < f0);
    junk=findPeak(f(keep),P(keep));
    NoiseCal(iteration)=junk(2);
    index=1:iteration;
    NoiseMean=mean(NoiseCal(index));
    RelErr=std(NoiseCal(index))/sqrt(iteration);
    RelErr=RelErr/NoiseMean;
    fprintf('%d : %g %.4f\n',iteration,NoiseMean,RelErr);
    if iteration < 20
        continue
    elseif  RelErr < 1e-3
        break
    end
end
extra.NoiseArtifaceCalibration=NoiseMean;

% analyze boundary regions
Nboundary=numel(boundary);
raw=analyze(data,@processBlock);
    function parameter=processBlock(spectrum,local)
        parameter=nan(2,Nboundary);
        tmid=(local.Grid(end)+local.Grid(1))/2;
        for nn=1:Nboundary
            [fA,fB]=probe(boundary{nn},tmid);
            if isnan(fA)
                continue
            end
            center=(fA+fB)/2;
            left=min(fA,center-minwidth);
            right=max(fB,center+minwidth);
            while true
                temp=crop(spectrum,[left right]);
                value=findPeak(temp.Grid,temp.Data);
                if value(1) < fA
                   left=(2*left+fA)/3; 
                elseif value(2) > fB
                    right=(2*right+fB)/3;
                else
                    break
                end                
            end           
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
for n=1:Nboundary
    temp=raw.Data(:,[2*n-1 2*n]);
    keep=~isnan(temp(:,1));
    temp=temp(keep,:); 
    temp(:,2)=sqrt(temp(:,2)/AmplitudeCalibration); % calibrated signal amplitude
    temp(:,3)=duration; % effective duration
    result{n}=SMASH.SignalAnalysis.SignalGroup(t(keep),temp);
    result{n}.Name=boundary{n}.Label;
    result{n}.GridLabel='Time';
    result{n}.Legend={'Frequency' 'Signal amplitude' 'Effective duration'};
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

% function result=findPeak(x,y,minwidth)
% 
% FullArea=trapz(x,y);
% centroid=trapz(x,x.*y)/FullArea;
% 
% Npeak=2;
% x0=zeros(Npeak,1);
% y0=zeros(Npeak,1);
% for n=1:Npeak
%     [y0(n),index]=max(y);
%     keep=(abs(x-(x(index))) < minwidth);
%     LocalArea=trapz(x(keep),y(keep));
%     x0(n)=trapz(x(keep),x(keep).*y(keep))/LocalArea;
%     y(keep)=0;
% end
% 
% if (trapz(x,y)/FullArea) > 0.05
%     x0=centroid;
%     y0=FullArea/x(end);
% else
%     x0=sum(x0.*y0)/sum(y0);
%     y0=mean(y0);
% end
% 
% result=[x0 y0];
% 
% 
% 
% % full centroid
% % FullArea=trapz(x,y);
% % FullCenter=trapz(x,x.*y)/FullArea;
% % FullAmplitude=FullArea/x(end);
% % 
% % % local centroid
% % 
% % 
% % LocalCenter=trapz(x(keep),x(keep).*y(keep))/LocalArea;
% % 
% % % weighted average
% % %weight=FullArea/(LocalArea*x(end)/(2*minwidth));
% % %weight=sqrt(LocalArea/FullArea);
% % weight=LocalArea/FullArea;
% % %weight=LocalAmplitude/FullAmplitude;
% % %weight=FullAmplitude/LocalAmplitude;
% % %ratio=(LocalAmplitude-FullAmplitude)/FullAmplitude;
% % %weight=1-exp(-ratio);
% % 
% % x0=(1-weight)*FullCenter+weight*LocalCenter;
% % y0=(1-weight)*FullAmplitude+weight*LocalAmplitude;
% % result=[x0 y0];
% % 
% % % if weight < 0.75
% % %     keyboard
% % % end
% % 
% % % weight=min(weight,1);
% % % 
% % % 
% % % if  width > (2*minwidth)
% % %     result=[center; area/width];
% % %     return
% % % end
% % % 
% % % % refine peak
% % % [~,index]=max(y);
% % % xmax=x(index);
% % % if (abs(xmax-center) > minwidth)
% % %     return
% % % end
% % % 
% % % index=(abs(x-xmax) <= width);
% % % xk=x(index);
% % % yk=y(index);
% % % 
% % % Ly=max(yk);
% % % yk=yk/Ly;
% % % 
% % % x1=min(xk);
% % % x2=max(xk);
% % % Lx=x2-x1;
% % % xk=(xk-x1)/Lx;
% % % 
% % % param=polyfit(xk,yk,2);
% % % if param(1) >= 0
% % %     return
% % % end
% % % x0=-param(2)/(2*param(1));
% % % y0=polyval(param,x0);
% % % 
% % % result=[x1+x0*Lx Ly*y0];
% 
% end