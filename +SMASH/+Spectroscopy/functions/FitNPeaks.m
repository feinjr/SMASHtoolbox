function [FinalFit,PeakLocations,PeakWidths,Amplitude]=FitNPeaks(x,y,locationGuess,widthGuess)
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
    
    object=SMASH.CurveFit.Curve;
    gauss=@(p,x) exp(-(x-p(1)).^2/(2*p(2).^2)); %Gaussian Fit of data
    object=add(object,gauss,[guess(1) guess(2)]);
    object=fit(object,[PixelRange(:) LineoutRange(:)]);
    param=cell2mat(object.Parameter);
    PeakLocations(end+1)=param(1); %#ok<AGROW>
    PeakWidths(end+1)=param(2)*2.355; %#ok<AGROW>
    Amplitude(end+1)=cell2mat(object.Scale); %#ok<AGROW>
    FinalFit=FinalFit+evaluate(object,x);
    %becomes a problem when the baseline is not ~0.
    index0=index;
end
end