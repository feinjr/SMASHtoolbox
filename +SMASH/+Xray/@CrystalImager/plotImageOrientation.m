function [ varargout ] = plotImageOrientation( object )
%% [ varargout ] = plotImageOrientation( object )
%
% This method plots an image showing the orientation of the TIPC image
% plate relative to each image channel and the Anode and Cathode of the
% machine.  This is meant to provide a visual guide for the user when
% rotating the raw image and selecting each of the channels.
%
%   output: optional output returns the figure handle
%
% See also TIPC, Xray, Image, Radiography
% created March 1, 2017 by Patrick Knapp (Sandia National Laboratories)
%
figure('Units','Inches','Position',[7,6,10,4],'Color','w','PaperPositionMode','auto')
hold on
axis equal

xColumn = [5,5,11,11];
yColumn = [2.9,3.1,3.1, 2.9];

if object.Settings.Shot < 2852
    xpatch = [1,15,15,2,1];
    ypatch = [5,5,1,1,2];
    
    patch(xpatch,ypatch,'k')
    patch(xColumn,yColumn,'w')
    xlim([0,16])
    ylim([0 6])
    
    text(13,3,'Cathode','Color','w','FontSize',16)
    text(1.25,3,'Anode','Color','w','FontSize',16)
    text(14.7,4.5,'Notch','Color','k','FontSize',10)
    text(7,3.5,'Image','Color','w','FontSize',12)

elseif object.Settings.Shot >= 2852
    xpatch = [1,14,15,15,1];
    ypatch = [5,5,4,1,1];
    
    patch(xpatch,ypatch,'k')
    patch(xColumn,yColumn,'w')
    xlim([0,16])
    ylim([0 6])
    
    text(13,3,'Cathode','Color','w','FontSize',16)
    text(1.25,3,'Anode','Color','w','FontSize',16)
    text(14.7,4.5,'Notch','Color','k','FontSize',10)
    text(7,3.5,'Image','Color','w','FontSize',12)    
end

title('Crystal Imager Image Orientation')
varargout{1} = gcf;
end

