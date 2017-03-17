function [ object ] = summarize( object, varargin )
%% [ object ] = summarize( object, varargin )
%
%
%% setup defaults and unpack parameters
Nslices = object.Settings.Nslices;
yLimits = [-0.4,0.44];
Print = false;

for i = 1:length(varargin)
    if strcmp(varargin{i},'yLimits'); yLimits = varargin{i+1};
    elseif strcmp(varargin{i},'Print'); Print = true;
    end
end

%%
YY = zeros(Nslices,1);

Integral = zeros(Nslices, 1);
COM = zeros(Nslices, 1);
width = zeros(Nslices, 2);
Lineouts = zeros(length(object.Image.Grid1), Nslices);

dy = diff(yLimits)/Nslices;

for n = 1:Nslices
    %%%% Crop axial slice and integrate into lineout 
    yCrop = [yLimits(1) + (n-1)*dy, yLimits(1) + n*dy];
    YY(n) = mean(yCrop);
    temp = crop(object.Image,[],[yCrop(1) yCrop(2)]);    
    lineout = SMASH.SignalAnalysis.Signal(temp.Grid1, abs(trapz(temp.Grid2,temp.Data,1)));    
    Lineouts(:,n) = lineout.Data;

    %%%% create a gaussian fit to the lineout and find the peak and width
    cfit = SMASH.CurveFit.Curve;
    gaussian=SMASH.CurveFit.makePeak('gaussian');
    
    cfit=add(cfit,gaussian,[0 0.01],'lower',[-0.05 1e-4], 'upper',[0.05 0.5],'scale',1,'fixscale',false);
    cfit = fit(cfit,[lineout.Grid, lineout.Data]);
    peak = cfit.Parameter{1}(1);
    sigma = cfit.Parameter{1}(2);
    
    %%%% Caclculate intensity and COM
    lineout_4sigma = crop(lineout, [cfit.Parameter{1}(1)-4*sigma cfit.Parameter{1}(1)+4*sigma]);
    Integral(n) = trapz(lineout_4sigma.Grid,lineout_4sigma.Data);
    COM(n) = trapz(lineout_4sigma.Grid,lineout_4sigma.Grid.*lineout_4sigma.Data)/trapz(lineout_4sigma.Grid,lineout_4sigma.Data);
    
    %%%%% Calculate right side width
    lineout_half = crop(lineout, [COM(n) COM(n)+3*sigma]);
    minval = min(lineout_half.Data);
    integral = cumtrapz(lineout_half.Grid-COM(n),lineout_half.Data+minval);
    integral = integral/max(integral);   
    idx = find(integral >= 0.85,1, 'first');
    width(n,1) = lineout_half.Grid(idx);
    
    %%%%% Calculate left side width
    
    lineout_half = crop(lineout, [COM(n)-3*sigma COM(n)]);
    minval = min(lineout_half.Data);
    integral = cumtrapz(abs(lineout_half.Grid(end:-1:1)-COM(n)),lineout_half.Data(end:-1:1)+minval);
    integral = integral/max(integral);       
    idx = find(integral >= 0.85,1, 'first');
    width(n,2) = lineout_half.Grid(numel(lineout_half.Grid)-idx);
    
end

%% Load summary measurements into output structure
p = struct();
p.Height = YY;
p.Center = COM;
p.Intensity = Integral;
p.RightSide = abs(COM - width(:,1));
p.LeftSide = abs(COM - width(:,2));
p.Width = abs(width(:,1)-width(:,2));

p.Volume = trapz(p.Height,pi*(p.Width/2).^2);

p.IntensityMean = mean(p.Intensity);
p.IntensityDeviation = std(p.Intensity);

p.RadiusMean = mean(p.Width)/2;
p.RadiusDeviation = std(p.Width/2);

p.PositionDeviation = std(p.Center);
p.RmsPostion = sqrt(mean(p.Center.^2));

p.Lineouts = Lineouts;
p.Axis = object.Image.Grid1;

object.Summary = p;

if Print
    % determine label format
    name=fieldnames(object.Settings);
    L=max(cellfun(@numel,name));
    name=fieldnames(object.Settings);
    L=max(L,max(cellfun(@numel,name)));
    format=sprintf('\t%%%ds : ',L);

    fprintf('*** Crystal Imager Summary Values ***\n');
    name=fieldnames(p);
    name=sort(name);
    for k=1:numel(name);
        value = p.(name{k});
        if isscalar(value)
            fprintf(format,name{k});
            fprintf('%.6g ',value);
            fprintf('\n');
        end
    end
    fprintf('\n');
    return
end

end
