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
%           value of MI is found.
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
    if strcmp(varargin{i},'Parameters');
        newparams = varargin{i+1};
        fields = fieldnames(newparams);
        for n = 1:numel(fields)
            Parameters.(fields{n}) = newparams.(fields{n});
        end
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
img1=shift(img1,'Grid1',-1*report1.Location);
findmid1 = mean(img1,'Grid1',[]);
new1 = differentiate(findmid1);
midpoint1 = (max(new1.Grid) + min(new1.Grid))/2;
img1 = shift(img1,'Grid2',-1*midpoint1);
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
        img2_interp = regrid(img2, img2.Grid1(1):dx_new:img2.Grid1(end),img2.Grid2(1):dx_new:img2.Grid2(end));
        im2 = img2_interp.Data;
        
        X_off = round((size(im2,2)-size(im1,2)-1)*rand(Number_Samples,1))+1;
        Y_off = round((size(im2,1)-size(im1,1)-1)*rand(Number_Samples,1))+1;
        mutualInfo = zeros(size(X_off));
        
        im1 = round(im1);
        im2 = round(im2);
        
        for k = 1:length(X_off)
            J=im2(Y_off(k):(Y_off(k)+size(im1,1)-1),X_off(k):(X_off(k)+size(im1,2)-1));
            mutualInfo(k) = mutualinformation(im1,J);
        end
        
        zgrid = RegularizeData3D(X_off,Y_off,mutualInfo,1:1:(size(im2,2)-size(im1,2)),1:1:(size(im2,1)-size(im1,1)),'smoothness',0.0001, 'interp', 'bicubic');
        [X,Y] = meshgrid(1:1:(size(im2,2)-size(im1,2)),1:1:(size(im2,1)-size(im1,1)));

        [~,idx] = min(exp(-zgrid(:)));
        J = X(idx); I = Y(idx);

        if showMI
            figure
            hold on
            pcolor(X,Y,exp(-zgrid))
            shading flat
            scatter(J,I,zgrid(idx),'Marker','o','MarkerEdgeColor','w');
        end        
        im_matched=img2_interp.Data(I:(I+size(im1,1)-1),J:(J+size(im1,2)-1));
        
        if Parameters.Optimize
            %in development
            data.im1 = img1_interp;
            data.im2 = img2_interp;
            %figure
            options = optimset('MaxIter',1000, 'MaxFunEvals',1000,'TolFun', 1e-5);%,'PlotFcns',@optimplotfval);
            x0 = [-(img2_interp.Grid1(J)-img1_interp.Grid1(1)), -(img2_interp.Grid2(I)-img1_interp.Grid2(1))];
            
            basis = @(p) shiftMI( p(1), p(2) , data);
            x = fminsearch(basis,x0, options);
            im2_temp = shift(img2_interp,'Grid1',x(1));
            im2_temp = shift(im2_temp,'Grid2',x(2));
            im2_temp = regrid(im2_temp,img1_interp.Grid1,img1_interp.Grid2);
            im_matched = im2_temp.Data;
        end
        
        if showFuse
            im_fused = fuse(img1_interp.Data,im_matched);
            figure; imagesc(im_fused);
        end
        
        images_reg(:,:,i) = im_matched;
    end
end

imgs_reg = SMASH.ImageAnalysis.ImageGroup(img1_interp.Grid1,img1_interp.Grid2,images_reg);
dx = (img1.Grid1(2) - img1.Grid1(1));
X = img1_interp.Grid1(1):dx:img1_interp.Grid1(end);
Y = img1_interp.Grid2(1):dx:img1_interp.Grid2(end);

imgs_reg = regrid(imgs_reg, X, Y);

imgs_reg.GraphicOptions.AspectRatio = 'equal';
imgs_reg.GraphicOptions.YDir = 'normal';
object.RegisteredImages = imgs_reg;
object.RegisteredImages.Legend = {'a','b','c','d','e'};


    function MI = shiftMI( xShift, yShift, options )
        I1 = options.im1;
        I2 = options.im2;
        
        temp = shift(I2,'Grid1',xShift);
        temp = shift(temp,'Grid2',yShift);
        
        temp = regrid(temp,I1.Grid1,I1.Grid2);
        MI = exp(-mutualinformation(round(I1.Data),round(temp.Data)));
    end

end

