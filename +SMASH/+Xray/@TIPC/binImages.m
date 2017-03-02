function [ object ] = binImages( object, varargin )
%% [ object ] = binImages( object, varargin )
%
% This method takes the fully processed and registered TIPC images bins
% them axially and integrates them radially.  It also estimates the
% uncertainty in the resulting intensity values.  The
% object.Settings.Nslices property is used to determine how many bins to
% create.  The output is given as a structure in the object.Summary
% property.
%   object.Summary = s;
%   s.Yvalues: [Nslices x 1] array.  Y-location of the center of each bin
%   s.Intensity: [Nslices x Nchannels] integrated intensity at each slice
%   s.Uncertainty: [Nslices x Nchannels] estimate of uncertainty
%
% Property/Value pairs
%   'yLimits':  [2x1] array giving the minimum and maximum height values of
%               the image.
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
yLimits = [-0.3 0.4];
Nslices = object.Settings.Nslices;
output = struct();
Nchannels = object.Settings.NumberImages;

res_orig = (object.Measurement.Grid1(end)-object.Measurement.Grid1(1))/(numel(object.Measurement.Grid1)-1);
res_final = (object.Images.Grid1(end)-object.Images.Grid1(1))/(numel(object.Images.Grid1)-1);
res_scale = res_final/res_orig;

for i = 1:length(varargin)
    if strcmp(varargin{i},'yLimits'); yLimits = varargin{i+1};
    end    
end

YY = zeros(Nslices,1);

Integral = zeros(Nslices, Nchannels);
Errors = zeros(Nslices, Nchannels);

dy = diff(yLimits)/Nslices;

for i = 1:Nchannels
    for n = 1:Nslices
        yCrop = [yLimits(2) - (n-1)*dy, yLimits(2) - n*dy];
        if i == 1
           YY(n) = mean(yCrop); 
        end
        temp = crop(object.Images,[],[yCrop(2) yCrop(1)]);
        hpts = length(temp.Grid2)/res_scale;
        
        lineout = SMASH.SignalAnalysis.Signal(temp.Grid1, trapz(temp.Grid2,temp.Data(:,:,i),1));
        
        cfit = SMASH.CurveFit.Curve;
        gaussian=SMASH.CurveFit.makePeak('gaussian');        

        cfit=add(cfit,gaussian,[0 0.01],'lower',[-0.05 1e-4], 'upper',[0.05 0.5],'scale',1,'fixscale',false);
        cfit = fit(cfit,[lineout.Grid, lineout.Data]);        
        y = evaluate(cfit,lineout.Grid);
        Integral(n,i) = trapz(lineout.Grid,y);
        
        width = cfit.Parameter{1}(2);
        peak = cfit.Parameter{1}(1);
        background1 = crop(lineout,[min(lineout.Grid), peak-3*width]);
        background2 = crop(lineout,[peak+3*width, max(lineout.Grid)]);
        Errors(n,i) = std([background1.Data; background2.Data])/sqrt(abs(Integral(n,i)^2)+1)/sqrt(length(y)/res_scale + hpts);
    end
end
output.Yvalues = YY;
output.Intensity = Integral;
output.Uncertainty = Errors;

object.Summary = output;
end

