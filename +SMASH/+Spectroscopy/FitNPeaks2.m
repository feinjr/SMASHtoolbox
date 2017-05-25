function [FinalFit,PeakLocations,PeakWidths,Amplitude]=FitNPeaks2(x,y,locationGuess,widthGuess)
%location here is the index, but it returns the actual location
location=locationGuess(:);
width=widthGuess(:);
[location, SortIndex] = sort(location);
width=width(SortIndex);

FinalFit=x*0;
PeakLocations=[];
PeakWidths=[];
Amplitude=[];
index0=1;
for i=1:length(location)
    if i==length(location)
        index=round(length(x));
    else
        index=round((location(i)+location(i+1))/2.0);
    end
    
    PixelRange=x(index0:index);
    LineoutRange=y(index0:index);
    guess(1)=x(location(i));
    guess(2)=width(i);
    [param,~]=fitGauss(PixelRange,LineoutRange,guess);
    gauss=param(1)*(exp(-(x-param(2)).^2/(2*param(3)^2)));
    FinalFit=FinalFit+gauss; %continues to add the seperate fits together,
    PeakLocations(end+1)=param(2); %#ok<AGROW>
    PeakWidths(end+1)=param(3)*2.355; %#ok<AGROW>
    Amplitude(end+1)=param(1); %#ok<AGROW>
    %becomes a problem when the baseline is not ~0.
    index0=index;
end
end

function [param,fit]=fitGauss(x,y,guess)
x=x(:);
y=y(:);
p=[];
param=[];
matrix=ones(numel(x),1); %only searching now for 1 linear parameter, the amplitude.
%Subtract background before using this to account for the variable background on SVS 1 and 2.

[MinimizedFunction,fval,exitflag]=fminsearch(@residual,guess);
if exitflag==0 || exitflag==-1
    warning('Matlab:Exiting','Did not converge')
end
[~,fit]=residual(MinimizedFunction);
    function [chi2,fit]=residual(current)
        x0=current(1);
        sigma=current(2);
        matrix(:,1)=exp(-(x-x0).^2/(2*sigma^2));
        p=matrix\y;
        fit=matrix*p;
        chi2=sum((fit-y).^2);
        param=[p(1) x0 sigma];
    end
end






