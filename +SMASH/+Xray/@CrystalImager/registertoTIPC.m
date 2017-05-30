function [ object ] = registertoTIPC( object, reference, varargin )
View = false;
%%
xCrop = [-0.3, 0.3];
yCrop = [-0.6, 0.6];
for i = 1:length(varargin)
    if strcmp(varargin{i}, 'XCrop'); xCrop = varargin{i+1}; end
    if strcmp(varargin{i}, 'YCrop'); yCrop = varargin{i+1}; end
    if strcmpi(varargin{i},'view'); View = true; end
end

%% find smallest region where images overlap and crop images to that region
objxLims = [object.Image.Grid1(1) object.Image.Grid1(end)];
objyLims = [object.Image.Grid2(1) object.Image.Grid2(end)];

refxLims = [reference.Grid1(1) reference.Grid1(end)];
refyLims = [reference.Grid2(1) reference.Grid2(end)];

xLims = [max(objxLims(1),refxLims(1)), min(objxLims(2),refxLims(2))];
yLims = [max(objyLims(1),refyLims(1)), min(objyLims(2),refyLims(2))];

objcrop = crop(object.Image,xLims,yLims);
refcrop = crop(reference,xLims,yLims);

%% regrid TIPC image onto new finer grid
objcrop = bin(objcrop, 5);
objcrop.Grid2
refcrop = regrid(refcrop, objcrop.Grid1,objcrop.Grid2);
refcrop = crop(refcrop,xCrop,yCrop);

[~, shifts] = registerGUI( refcrop, objcrop);

object.Image = shift(object.Image,'Grid1',shifts(1));
object.Image = shift(object.Image,'Grid2',shifts(2));

if View
    los = mean(object.Image,'Grid1');
    lot = mean(reference,'Grid1');
    figure; hold all; plot(lot.Grid,lot.Data/max(lot.Data)); plot(los.Grid,los.Data/max(los.Data));
    legend('TIPC','Crystal Imager');
    
    los = mean(object.Image,'Grid2');
    lot = mean(reference,'Grid2');
    figure; hold all; plot(lot.Grid,lot.Data/max(lot.Data)); plot(los.Grid,los.Data/max(los.Data));  
    legend('TIPC','Crystal Imager');
end
end

