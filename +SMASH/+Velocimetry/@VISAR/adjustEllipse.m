% ADJUSTELLIPSE - Calculates the vertical offsets and scaling to generate a 
% centered Lissajou with a magnitude of 1. 
%
% This method calculates the offsets and scalings for the Quadrature signal
% of a VISAR object to obtain a centered Lissajou with unit magnitude.  The
% possible syntaxes are below.
%      >> object=adjust(object,percentage);
%      >> object=adjust(object);
%
% Percentage defines the range around each axis intercept to use for
% determining the scalings.  This percentage is defined by the range of the
% signal along the opposite axis.  The default is 5%.
%
% For a Fast Push-Pull signal, each axis crossing is given is own
% independent scaling.  For Conventional and Standard Push-Pull signals,
% the scales for both crossings of each axis are averaged to determine the
% signal scaling.
%
% The vertical scales and offsets are not protected properties.  The user
% can specifiy them in the command window.
%     >> object.Verticaloffsets=[f1 f2 f3 f4];
%     >> object.VertialScales=[s1 s2 s3 s4];
%
% The first offset and scaling apply to the first signal.  If only one
% offset and scaling are entered, only the first signal is scaled and 
% shifted.  If the number of offsets or scalings exceed the number of 
% signals, the addtional offsets or scalings are ignored.  
%
% created March 15 2016 by Paul Specht (Sandia National Laboratories)

function object=adjustEllipse(object,percent)

%handle inputs
if nargin == 1
    percent=0.05;
elseif nargin == 2
    if isnumeric(percent)
        if numel(percent) == 1
            percent=abs(percent);
            if percent > 1
                percent=percent/100;
            end
            if percent > 0.2
                error('ERROR: Percentage Must be Under 20%');
            end
        else
            error('ERROR: Percentage Must be Scalar');
        end
    else
        error('ERROR: Percentage Must be Numeric');
    end
end

%reset the vertical offsets and scalings
N=object.Measurement.NumberSignals;
object.VerticalOffsets=zeros(1,N);
object.VerticalScales=ones(1,N);

%calculate the offsets
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
if isa(object.Processed,'SMASH.SignalAnalysis.Signal') ~= 1
    objtemp=analyze(object);
else
    objtemp=object;
end

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


    


    

