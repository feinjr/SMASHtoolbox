function [ object ] = segmentImages( object, varargin )
%% [ object ] = segmentImages( object, varargin )
%
% This method takes a TIPC object as input and allows the user to break the
% full image into one image for each channel.  This is done by graphically
% selecting a point on each image, around which a box will be drawn that is
% used to crop each image.  Each image is placed on the same X- and Y-
% grids and an ImageGroup object is created, which is used to populate the
% object.Images property.
%
% Property/Value pairs to control functionality:
%       'BoxSize': [2x1] array giving the dimensions in X and Y of the
%       cropped images
%       'DataLim': [2x1] array giving the display limits of the colormap.
%       The image contrast may require adjustment in order to see all
%       channels at the same time.
%       'Offset': [2x1] array. default is [0,0], assuming that the point
%       selected on each image is nominally at the center of the image.  If
%       this is not the case, add an offset (in cm) so that the resulting
%       crop box is centered on the image.
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
%%

Nchannels = object.Settings.NumberImages;
dx =(object.Measurement.Grid1(end)-object.Measurement.Grid1(1))/(numel(object.Measurement.Grid1)-1);

% Set default parameters
DataLim = [0 1500]; % data limits to display image
BoxSize = [2,2];    % segmentation image size in centimeters
Offset = [0,0];     % offset from center of image to selection point

for i = 1:length(varargin)
    if strcmp(varargin{i},'BoxSize'); BoxSize = varargin{i+1};
    elseif strcmp(varargin{i},'DataLim'); DataLim = varargin{i+1};
    elseif strcmp(varargin{i},'Offset'); Offset = varargin{i+1};
    end    
end

xrect = [-BoxSize(1)/2, BoxSize(1)/2, BoxSize(1)/2, -BoxSize(1)/2, -BoxSize(1)/2];
yrect = [-BoxSize(2)/2, -BoxSize(2)/2, BoxSize(2)/2, BoxSize(2)/2, -BoxSize(2)/2];

% Display and select approximate center of each image
object.Measurement.DataLim = DataLim;
h = view(object.Measurement);
hold all
[Xc,Yc] = getpts(h.figure);
Xc = Xc + Offset(1);
Yc = Yc + Offset(2);

% crop each image
images = cell(Nchannels,1);
minX = zeros(Nchannels,1);
maxX = zeros(Nchannels,1);
minY = zeros(Nchannels,1);
maxY = zeros(Nchannels,1);

for n = 1:length(Xc)
    for i = 1:length(xrect)-1
        plot([xrect(i) xrect(i+1)]+Xc(n),[yrect(i), yrect(i+1)]+Yc(n),'Color','w');
    end
    images{n} = crop(object.Measurement,[Xc(n) - BoxSize(1)/2, Xc(n) + BoxSize(1)/2],[Yc(n) - BoxSize(2)/2, Yc(n) + BoxSize(2)/2]);
    images{n} = shift(images{n},'grid1',-Xc(n));
    images{n} = shift(images{n},'grid2',-Yc(n));
    
    minX(n) = min(images{n}.Grid1);
    maxX(n) = max(images{n}.Grid1);
    minY(n) = min(images{n}.Grid2);
    maxY(n) = max(images{n}.Grid2);
end

% regrid to ensure all images are on same x and y grids
grid1 = max(minX):dx:min(maxX);
grid2 = max(minY):dx:min(maxY);
I = zeros(length(grid2),length(grid1),Nchannels);

for i = 1:Nchannels
   images{i} = regrid(images{i},grid1,grid2);
   I(:,:,n) = images{n}.Data;
end

%  collect all images into an imagegroup object
imgs = SMASH.ImageAnalysis.ImageGroup(images{1}.Grid1,images{1}.Grid2,I);
imgs.GraphicOptions.AspectRatio = 'equal';
imgs.GraphicOptions.YDir = 'normal';

object.Images = imgs;
object.Images.Legend = {'a','b','c','d','e'};

end

