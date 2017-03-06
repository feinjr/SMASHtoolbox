function history=analyzeRobust(data,boundary,param)

% initial preparations
data.FFToptions.FrequencyDomain='positive';
data.FFToptions.SpectrumType='power';

% perform calibration
duration=data.Partition.Duration;
T=param.SampleInterval;
fs=1/T;

t=0:T:duration;
f0=fs/4;
s=cos(2*pi*f0*t);
temp=SMASH.SignalAnalysis.Signal(t,s);
[f,P]=fft(temp,data.FFToptions);
[calibration,minwidth]=findPeak(f,P,[]);
switch data.FFToptions.Window
    case 'hann'
        duration=duration*(0.34/0.58);
    case 'hamming'
        duration=duration*(0.37/0.58);
end


% analyze boundary regions
Nboundary=numel(boundary);
result=analyze(data,@processBlock);
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
                value=findPeak(temp.Grid,temp.Data,minwidth);
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

% format results
t=result.Grid;

history=cell(Nboundary,1);
for n=1:Nboundary
    temp=result.Data(:,[2*n-1 2*n]);
    keep=~isnan(temp(:,1));
    temp=temp(keep,:);
    temp(:,2)=param.RMSnoise./sqrt(temp(:,2)/calibration(2)); % noise fraction
    temp(:,2)=sqrt(6/(fs*duration^3))*temp(:,2)/pi;    
    history{n}=SMASH.SignalAnalysis.SignalGroup(t(keep),temp);
    history{n}.Name=boundary{n}.Label;       
end

end

function [result,width]=findPeak(x,y,minwidth)

% calculate centroid
area=trapz(x,y);
weight=y/area;
center=trapz(x,weight.*x);
width=sqrt(trapz(x,weight.*(x-center).^2));

result=[center; area/width];
if isempty(minwidth)
    return
end

% refine peak
[~,index]=max(y);
xmax=x(index);
if (abs(xmax-center) > minwidth)
    return
end

index=(abs(x-xmax) <= width);
xk=x(index);
yk=y(index);

Ly=max(yk);
yk=yk/Ly;

x1=min(xk);
x2=max(xk);
Lx=x2-x1;
xk=(xk-x1)/Lx;

param=polyfit(xk,yk,2);
if param(1) >= 0
    return
end
x0=-param(2)/(2*param(1));
y0=polyval(param,x0);

result=[x1+x0*Lx Ly*y0];
if any(result(2) < 0)
    keyboard
end

end