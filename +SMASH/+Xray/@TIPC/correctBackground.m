function [ object ] = correctBackground( object, varargin )
%% [ object ] = correctBackground( object, varargin )
%
% This method takes a TIPC object as input and operates on the
% object.Images property to estimate the spatially varying background
% exposure and correct for it.  The user is prompted to select the region
% of the image containing data, then points are randomly selected outside
% of this region.  A surface interpolation routine is used to estimate the
% background surface and subtract it from the images.  This method loops
% through all images.  The background surface can be plotted by passing the
% keyword 'ShowPlot' as an input.
%
% Adjusting the default parameters using the property/value pair
% 'Parameters'/p where p is a structure with fields:
%       p.Npts: number of points to use for surface estimation.  default is
%           500.
%       p.Smoothing: smoothing parameter for interpolation.  default is
%           0.0001.  Larger values will allow the surface to deviate from the
%           interpolation points more in favor of a smoother surface.  Smaller
%           values will try to interpolate exactly through the data points,
%           resulting in less smoothness.
%       p.InterpolationMethod: default is 'bicubic'.  Other options are
%           'bilinear' and 'triangle'.  See documentation for
%           RegularizeData3D.m for more info.  
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
Parameters = struct();
Parameters.Npts = 500;
Parameters.Smoothing = 0.0001;
Parameters.InterpolationMethod = 'bicubic';
show = false;

for i = 1:length(varargin)
    if strcmp(varargin{i},'Parameters'); 
        newparams = varargin{i+1};
        fields = fieldnames(newparams);
        for n = 1:numel(fields)
           Parameters.(fields{n}) = newparams.(fields{n}); 
        end

    elseif strcmp(varargin{i},'ShowPlot'); show = true;
    end    
end

imgs = object.Images;
images_bkg = zeros(size(imgs.Data));
X = imgs.Grid1; Y = imgs.Grid2;

%%%%%%%%%%%%%%%%%%%%%%%%%%% create informative dialog box
diaReg=SMASH.MUI.Dialog;
diaReg.Hidden=true;
diaReg.Name='Select Data Region';

htxt1=addblock(diaReg,'text','Use pan/zoom to select region',[25]);
htxt2=addblock(diaReg,'text','conatining image data',[25]);
hReg=addblock(diaReg,'button',{' OK '});
set(hReg(1),'Callback',@callbackOK);

diaDone.Hidden=false;
uiwait
%%%%%%%%%%%%%%%%%%%%%%%%%% Callback functions for region selection
    function callbackOK(varargin)
        delete(diaReg);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:object.Settings.NumberImages
    img = SMASH.ImageAnalysis.Image(imgs.Grid1,imgs.Grid2,imgs.Data(:,:,n));
    
    mask = limit(img,'manual');
    xlims = [mask.LimitIndex1(1), mask.LimitIndex1(end)];
    ylims = [mask.LimitIndex2(1), mask.LimitIndex2(end)];
    
    xpts = round((length(X)-1)*rand(Parameters.Npts,1))+1;
    ypts = round((length(Y)-1)*rand(Parameters.Npts,1))+1;
    
    in = inpolygon(xpts, ypts, [xlims(1), xlims(2), xlims(2), xlims(1)],[ylims(1), ylims(1), ylims(2), ylims(2)]);
    
    x_keep = xpts(~in); y_keep = ypts(~in);
    xx = X(x_keep);
    yy = Y(y_keep);
    zz = zeros(size(x_keep));
    
    img_smooth = smooth(img,'mean',[8,8]);
    
    for i = 1:length(x_keep)
        zz(i) = img_smooth.Data(y_keep(i),x_keep(i));
    end
    
    zgrid = RegularizeData3D(xx,yy,zz,X,Y,'smoothness',Parameters.Smoothing, 'interp', Parameters.InterpolationMethod);
       
    if show
        figure; hold all
        imagesc(X,Y, zgrid)
    end
    images_bkg(:,:,n) = img.Data - zgrid;
    
%     figure; hold all
%     imagesc(X,Y, img.Data)%, [-100 500])
%     scatter(xx,yy,'m')
%     plot(X([xlims(1), xlims(2), xlims(2), xlims(1), xlims(1)]), Y([ylims(1), ylims(1), ylims(2), ylims(2), ylims(1)]),'Color','w')
    
end

imgs_bkg = SMASH.ImageAnalysis.ImageGroup(X,Y,images_bkg);
imgs_bkg.GraphicOptions.AspectRatio = 'equal';
imgs_bkg.GraphicOptions.YDir = 'normal';

object.Images = imgs_bkg;
object.Images.Legend = {'a','b','c','d','e'};
end

