function [ object ] = registerImages( object, varargin )
%% [ object ] = registerImages( object, varargin )
%
% This method takes a TIPC object as input and registers each image in the
% object.Images property to one image chosen as a reference.  The default
% refence image is image 1, but this can be chosen by the user.  The
% registration is accomplished using the image intensity only.  The "mutual
% information" between the two images is maximized by moving the images
% with respect to eachother and finding the offest with the highest value
% of this parameter.
% The map of mutual information can be shown for each image by passing the
% keyword 'ShowMI'.  A composite image of each pair of registered images
% can be shown by passing the keyword 'ShowFuse' (not yet implemented).
%
% Adjusting the default parameters using the property/value pair
% 'Parameters'/p where p is a structure with fields:
%       p.NumPts: number of points to use for MI surface estimation.  default is
%           500.
%       p.ResolutionFactor: Scale factor used to increase the resolution of the
%           images in order to provide better registration.  Default is 2
%       p.ReferenceImage: integer index of image to be used as reference.
%           default is 1.
%       p.FinalImageXLims and p.FinalImageYLims:  [2x1] array giving the
%           region to crop the final images to.
%       p.IntermediateImageXLims and p.IntermediateImageYLims:  [2x1] array giving the
%           region to crop the images to when performing registration.
%           This must be larger than FinalImageXLims and YLims.  
%       p.Optimize:  true or false.  Setting to true will enable a further 
%           optimization of the image registration once the initial maximum
%           value of MI is found.  Not yet implemented.
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%
Parameters = struct();
Parameters.ResolutionScaleFactor = 2;
Parameters.ReferenceImage = 1;
Parameters.NumPts = 500;
Parameters.FinalImageXLims = [-0.2 0.2];
Parameters.FinalImageYLims = [-0.6 0.6];
Parameters.IntermediateImageXLims = [-0.4 0.4];
Parameters.IntermediateImageYLims = [-0.8 0.8];
Parameters.Optimize = false;

showMI = false;
showFuse = false;

for i = 1:length(varargin)
    if strcmp(varargin{i},'Parameters'); Parameters = varargin{i+1};
    elseif strcmp(varargin{i},'ShowMI'); showMI = true;
    elseif strcmp(varargin{i},'ShowFuse'); showFuse = true;
    end    
end

%%
Nchannels = object.Settings.NumberImages;
res_scale = Parameters.ResolutionScaleFactor;
Number_Samples = Parameters.NumPts;
ref = Parameters.ReferenceImage;

img1 = SMASH.ImageAnalysis.Image(object.Images.Grid1,object.Images.Grid2,object.Images.Data(:,:,ref));

% shift and regrid reference image
findmean1 = mean(img1,'Grid2',[]);
report1 = locate(findmean1,'peak');
img1=shift(img1,'Grid1',-report1.Location);
findmid1 = mean(img1,'Grid1',[]);
new1 = differentiate(findmid1);
midpoint1 = (max(new1.Grid) + min(new1.Grid))/2;
img1 = shift(img1,'Grid2',-midpoint1);
img1 = crop(img1,Parameters.FinalImageXLims,Parameters.FinalImageYLims);

dx_new = (img1.Grid1(2) - img1.Grid1(1))/res_scale;
img1_interp = regrid(img1, img1.Grid1(1):dx_new:img1.Grid1(end),img1.Grid2(1):dx_new:img1.Grid2(end));
im1 = img1_interp.Data;

images_reg = zeros(size(img1_interp.Data,1),size(img1_interp.Data,2),Nchannels);
images_reg(:,:,1) = img1_interp.Data;

for i = 1:Nchannels
    if i ~= ref        
        % shift and regrid new images
        img2 = SMASH.ImageAnalysis.Image(object.Images.Grid1,object.Images.Grid2,object.Images.Data(:,:,i));
        xmid = (max(img2.Grid1) - min(img2.Grid1))/2 +min (img2.Grid1);
        findmean2 = mean(limit(img2,[xmid - 0.3, xmid + 0.3],'all'),'Grid2',[]);
        report2 = locate(findmean2,'peak');
        %Set images to zero axis. X-axis first
        filterI2=shift(img2,'Grid1',-report2.Location);
        %y-axis shift
        findmid2 = mean(img2,'Grid1',[]);
        new2 = differentiate(findmid2);
        %New grid final
        midpoint2 = (max(new2.Grid) + min(new2.Grid))/2;
        finalshift2 = shift(filterI2,'Grid2',-midpoint2);
        finalshift2 = crop(finalshift2,Parameters.IntermediateImageXLims,Parameters.IntermediateImageYLims);

        img2_interp = regrid(finalshift2, finalshift2.Grid1(1):dx_new:finalshift2.Grid1(end),finalshift2.Grid2(1):dx_new:finalshift2.Grid2(end));
        im2 = img2_interp.Data;
        
        X_off = round((size(im2,2)-size(im1,2)-1)*rand(Number_Samples,1))+1;
        Y_off = round((size(im2,1)-size(im1,1)-1)*rand(Number_Samples,1))+1;
        mutualInfo = zeros(size(X_off));
        
        im1 = round(im1);
        im2 = round(im2);
        
        for k = 1:length(X_off)
            J=im2(Y_off(k):(Y_off(k)+size(im1,1)-1),X_off(k):(X_off(k)+size(im1,2)-1));
            mutualInfo(k) = 1+mutualinformation(im1,J);
        end
        
        zgrid = RegularizeData3D(X_off,Y_off,mutualInfo,1:1:(size(im2,2)-size(im1,2)),1:1:(size(im2,1)-size(im1,1)),'smoothness',0.0001, 'interp', 'bicubic');
        [X,Y] = meshgrid(1:1:(size(im2,2)-size(im1,2)),1:1:(size(im2,1)-size(im1,1)));
        
        if showMI
            figure
            pcolor(X,Y,log10(1./zgrid))
            shading flat
        end
        
        [~,idx] = min(log10(1./zgrid(:)));
        J = X(idx); I = Y(idx);
        
        if Parameters.Optimize
            %not implemented
        end

        im_matched=img2_interp.Data(I:(I+size(im1,1)-1),J:(J+size(im1,2)-1));
        
        if showFuse
            c = imfuse(img1_interp.Data, im_matched, 'falsecolor');
            figure; imshow(c);
        end
        
        images_reg(:,:,i) = im_matched;
    end
end

imgs_reg = SMASH.ImageAnalysis.ImageGroup(img1_interp.Grid1,img1_interp.Grid2,images_reg);
imgs_reg.GraphicOptions.AspectRatio = 'equal';
imgs_reg.GraphicOptions.YDir = 'normal';
object.RegisteredImages = imgs_reg;
object.RegisteredImages.Legend = {'a','b','c','d','e'};

end

