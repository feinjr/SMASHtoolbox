function [location,amplitude,width]=FindPeaks(x,y,NPeaks,Threshold,Prominence)
%Returns the INDEX of the peaks
location=[];
amplitude=[];
width=[];
for i=1:NPeaks
    % look for peak
    [PeakValue,PeakIndex]=max(y);
    if PeakValue<Threshold
        break
    end
    FirstWidth=0;
    LeftIndex=1;
    RightIndex=1;
    for j=PeakIndex:-1:1
        if y(j)<0.5*PeakValue && FirstWidth==0
            width(end+1)=2*(x(PeakIndex)-x(j)); %#ok<AGROW>
            FirstWidth=1;
        end
        if j<PeakIndex-Prominence
            LeftIndex=PeakIndex-Prominence;
            RightIndex=PeakIndex+Prominence;
            break
        end
    end    
    location(end+1)=PeakIndex; %#ok<AGROW>
    amplitude(end+1)=PeakValue; %#ok<AGROW>
    y(LeftIndex:RightIndex)=0;
end
[location, SortIndex] = sort(location);
width=width(SortIndex);
amplitude=amplitude(SortIndex);
end