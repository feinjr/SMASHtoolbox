% Adjust - Calculate the vertical offsets and scalings for a VISAR object 
%
% This method calculates the offsets and scalings for a VISAR object to
% obtain as close to a unit circle as possible
%      >> object=adjust(object,percentage)
%
% Percentage defines the amount around each zero axis to use for to 
% determine the scaling paramaters. The default is 5%.
%
% created March 15 2016 by Paul Specht (Sandia National Laboratories) 

function object=adjust(object,percent)

%handle inputs
if nargin == 1
    percent=0.05;
elseif nargin == 2
    percent=abs(percent);
    if percent > 1
        percent=percent/100;
    end
    if percent > 0.1
        error('ERROR: Percentage Must be Under 10%');
    end
end

%reset the vertical offsets and scalings
object.VerticalOffsets=[];
object.VerticalScales=[];

%calculate the offsets
N=object.Measurement.NumberSignals;
bound=object.ExperimentalRegion;
roi=(object.Measurement.Grid >= bound(1)) & (object.Measurement.Grid <= bound(2));
if N == 4
    voffset=zeros(1,N);
else
    voffset=zeros(1,2);
end
for k=1:length(voffset);
    voffset(k)=-1*mean(object.Measurement.Data(roi,k));
end
object.VerticalOffsets=voffset;

%Process the Results to generate a centered Lissajou
objtemp=process(object);

%calculate scalings
X=objtemp.Quadrature.Data(:,1);
Y=objtemp.Quadrature.Data(:,2);
keep=cell(1,4);
scales=zeros(1,4);
%values for D1A
keep{1}=(abs(Y) <= 0.5*percent*max(Y)) & (X >= 0);
%values for D1B
keep{2}=(abs(Y) <= 0.5*percent*max(Y)) & (X <= 0);
%values for D2A
keep{3}=(abs(X) <= 0.5*percent*max(X)) & (Y >= 0);
%values for D2B
keep{4}=(abs(X) <= 0.5*percent*max(X)) & (Y <= 0);
for k=1:4
    if sum(keep{k}) ~= 0
        if k < 3
            scales(k)=1/mean(X(keep{k}));
        else
            scales(k)=1/mean(Y(keep{k}));
        end
    end
end
%adjust if don't have full ellipse
assert(sum(scales == 0) < 3,'ERROR: Experimental Region Too Short to Determine Vertical Scaling');
for m=1:4
    if scales(m) == 0
        if mod(m,2)
            scales(m)=scales(m+1);
        else
            scales(m)=scales(m-1);
        end
    end
end
%Use average scaling factores if not Fast Push-Pull since only 2 signals
if N < 4
    scales(1)=mean(scales(1:2));
    scales(2)=mean(scales(3:4));
    scales=scales(1:2);
end
object.VerticalScales=scales;


    


    

