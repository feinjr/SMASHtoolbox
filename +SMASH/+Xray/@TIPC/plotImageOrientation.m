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
Nchannels = object.Settings.NumberImages;

figure('Units','Inches','Position',[7,6,10,4],'Color','w','PaperPositionMode','auto')
hold on
axis equal

if Nchannels == 5
    xpatch = [1,15,15,2,1];
    ypatch = [5,5,1,1,2];
    
    patch(xpatch,ypatch,'k')
    xlim([0,16])
    ylim([0 6])
    
    text(7,1.3,'Cathode','Color','w','FontSize',16)
    text(7,4.7,'Anode','Color','w','FontSize',16)
    text(0.7,1.4,'Notch','Color','k','FontSize',10)
    
    xmid = 7.5;
    text(xmid,3,'a','Color','w','FontSize',25)
    text(xmid+2,3,'b','Color','w','FontSize',25)
    text(xmid-2,3,'c','Color','w','FontSize',25)
    text(xmid+4,3,'d','Color','w','FontSize',25)
    text(xmid-4,3,'e','Color','w','FontSize',25)
    
end
title('TIPC Image Orientation')
varargout{1} = gcf;
end

