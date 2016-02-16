%%
% This method of the Radiography class converts an exposure images to
% Transmission.  The user can interactively select locations of the image
% that correspond to full exposure or supply X,Y,Z values to use.  The
% function calls svd_surface to fit a surface to the selectef points and
% interpolate onto the original grid.  This full exposure surface is then
% divided out of the original image, producing a transmission image.
%
% If the user supplies points they should be in the form of 3 column
% vectors (one each for X, Y and Z).
%
% The polynomial order for surface fitting can be supplied using the
% property-value pair {'poly_order',n}. Default is n=2.  If poly_order = []
% is passed to the method then a dialog box will open allowing the user to
% dynamically adjust the order and see the results before committing.
%
%
% Created May 27, 2014 by Patrick Knapp (Sandia National Laboratories)

function [object, varargout] = calibrateTransmission(object,varargin)
%% Set default values
poly_order = 2;
X = []; Y = []; Z = [];
getzonepts = 1;

temp = object.Measurement;

%% Unpack variable inputs
for i=1:length(varargin)
    if strcmp(varargin{i},'poly_order'); poly_order=varargin{i+1};
    elseif strcmp(varargin{i},'show'); showplot = true;
    elseif strcmp(varargin{i},'XData'); X = varargin{i+1};
    elseif strcmp(varargin{i},'YData'); Y = varargin{i+1};
    elseif strcmp(varargin{i},'ZData'); Z = varargin{i+1};
    end
end

%% If no points supplied promt user to select regions
if isempty(X) && isempty(Y) && isempty(Z)
    diaReg=SMASH.MUI.Dialog;
    diaReg.Hidden=true;
    diaReg.Name='Select Region of 100% Transmission';
    set(diaReg.Handle,'Position',[1000, 918, 1200,  20])
    
    hReg=addblock(diaReg,'button',{' OK ', '  Exit  '});
    set(hReg(1),'Callback',@callbackOK);
    set(hReg(2),'Callback',@callbackExit);
    
    diaDone.Hidden=false;
    uiwait
    while getzonepts==1
        reg = region(temp);
        [X1,Y1] = meshgrid(reg.x,reg.y);
        
        X = [X; X1(:)];
        Y = [Y; Y1(:)];
        Z = [Z; reg.z(:)];

        diaDone=SMASH.MUI.Dialog;
        diaDone.Hidden=true;
        diaDone.Name='Select Another Region?';
        
        hDone=addblock(diaDone,'button',{' Yes ', '  No  '});        
        set(hDone(1),'Callback',@callback1);
        set(hDone(2),'Callback',@callback2);
        
        diaDone.Hidden=false;
        uiwait
    end
end

mask = ~isnan(Z);

if isempty(poly_order)
    figSurface=SMASH.MUI.Figure();
    figSurface.Name='Use Dialog Box to Set Surface Fit Parameters';
    setappdata(figSurface, 'surface', []);
    plot3(X(mask),Y(mask),Z(mask),'LineStyle','none','Marker','.')
    view(-45,45)
    ax1 = gca;
    
    
    %% Create Dialog box to manipulate image
    diaPoly=SMASH.MUI.Dialog;
    diaPoly.Hidden=true;
    diaPoly.Name='Choose Order of Fitting Polynomial';
    set(diaPoly.Handle,'Tag','guiFit');
    
    
    hPO=addblock(diaPoly,'edit',' Polynomial Order [0,1,2,...]',20); % Edit box to input rotation angle
    
    hUpdate=addblock(diaPoly,'button',' Update '); % update figure
    set(hUpdate,'Callback',@UpdateCallback); % rotates image by value in edit box and updates the figure
    
    hDone=addblock(diaPoly,'button',' Done '); % commits the rotation and grabs the new object
    set(hDone,'Callback',@DoneCallback);
    
    % Move dialog box so it doesn't overlap the figure window
    Pos_dia = get(diaPoly.Handle,'Position');
    Move_dia = [Pos_dia(3) 0 0 0];
    set(diaPoly.Handle,'Position',Pos_dia-Move_dia)
    
    diaPoly.Hidden=false;
    
    uiwait;
    
    ftx = getappdata(figSurface, 'SurfaceFit');
    close(figSurface.Handle);
    
else
    ftx = svd_surface(temp,X(mask),Y(mask),Z(mask),'polynomial',poly_order);
    
    if showplot
        figure
        hold on
        surf(temp.Grid1,temp.Grid2,ftx);
        shading flat
        view(-45,45)
        plot3(X(mask),Y(mask),Z(mask),'LineStyle','none','Marker','.')
        
    end
end
temp = temp./ftx;

object.Transmission = temp;
nout = max(nargout,1)-1;
if nout == 3
    varargout(1) = {X(mask)};
    varargout(2) = {Y(mask)};
    varargout(3) = {Z(mask)};
end
delete(diaPoly)

%% Callback functions for dialog box
    function UpdateCallback(varargin)
        value=probe(diaPoly);
        poly_order=sscanf(value{1},'%g');
        SurfaceFit = svd_surface(temp,X(mask),Y(mask),Z(mask),'polynomial',poly_order);
        
        axes(ax1);
        hold off
        surf(temp.Grid1,temp.Grid2,SurfaceFit,'Parent',ax1);
        hold on
        shading flat
        view(45,45)
        plot3(X(mask),Y(mask),Z(mask),'LineStyle','none','Marker','.','Parent',ax1)
        
        
    end

    function DoneCallback(varargin)
        delete(diaPoly);
        hData = findobj(ax1);
        SurfaceFit = get(hData(3),'CData');
        setappdata(figSurface, 'SurfaceFit', SurfaceFit);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%% Callback functions for region selection
    function callbackOK(varargin)
        getzonepts = 1;
        delete(diaReg);
    end
    function callbackExit(varargin)
        getzonepts = 0;
        delete(diaReg);
        return
    end
    function callback1(varargin)
        getzonepts = 1;
        delete(diaDone);
    end
    function callback2(varargin)
        getzonepts = 0;
        delete(diaDone);
    end

end

