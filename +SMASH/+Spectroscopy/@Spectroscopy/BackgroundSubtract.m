function InterpolatedBackground=BackgroundSubtract(pixel,lineout,varargin)
%Flat Background needs a value to subtract
%Polynomial needs an array of indices, and an order to fit the
%data.
%Median Filter needs an order usually around 100.
p=inputParser;
defaultValues=-1.0;
order=1; %default polynomical order

addRequired(p,'pixel');
addRequired(p,'lineout');

addOptional(p,'Flat',defaultValues,@isnumeric);

addOptional(p,'Polynomial',defaultValues,@isnumeric);
%Enter polynomial points like:
%xvalues=[1;2;3;4]; yvalues=[4;5;6;4] 2 columns
%poly=[xvalues,yvalues]
addOptional(p,'Order',order,@isnumeric);

addOptional(p,'MedianFilter',defaultValues,@isnumeric);
parse(p,pixel,lineout,varargin{:});

if strcmp(p.UsingDefaults, 'Flat')==0
    InterpolatedBackground=p.Results.Flat*ones(length(pixel),1);
elseif strcmp(p.UsingDefaults,'Polynomial')==0
    xvalues=p.Results.Polynomial(:,1);
    yvalues=p.Results.Polynomial(:,2);
    BackgroundPoly=polyfit(xvalues,yvalues,p.Results.Order);
    InterpolatedBackground=polyval(BackgroundPoly,pixel);
elseif strcmp(p.UsingDefaults,'MedianFilter')==0
    InterpolatedBackground=MedianFilter(pixel,lineout,p.Results.MedianFilter);
    InterpolatedBackground(1)=InterpolatedBackground(2);
else
    InterpolatedBackground=pixel*0;
end
end