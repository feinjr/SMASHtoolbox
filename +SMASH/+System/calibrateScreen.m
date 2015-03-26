% calibrateScreen : calibrate MATLAB's screen resolution
%
% MATLAB defaults to a system dependent DPI (dots per inch) setting that
% typically has no relation to the actual display resolution. This function
% displays a resizeable figure and asks the user to specify the actual
% width (in inches or centimeters).
%     >> calibrateScreen;
% Using the physical size information provided by the user, the actual DPI
% value is calculated and applied to the current MATLAB session.  The
% DPI value is also displayed in the command window.  To use the calibrated
% DPI in future sessions, add the following command to your startup file;
%       set(0,'ScreenPixelsPerInch',DPI);
%
% see also System
%

% created by February 23, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised March 26, 2015 by Daniel Dolan
%   -dropped log capability because it clashed with package paradigm
%   -DPI value displayed when the "Apply" button is pressed
function varargout=calibrateScreen(varargin)

% handle input
if nargin==0
    % do nothing
elseif (nargin==1) && strcmpi(varargin{1},'restore')
   restoreDPI; 
   return
else
    error('ERROR: invalid input');
end

% allow deployed applications
if isdeployed
    varargout{1}=0;
end

%% create GUI
fig=findall(0,'Type','figure','Tag','calibrateDPI');
if ishandle(fig)
    figure(fig);
    return
end

fig=figure(...
    'NumberTitle','off','Name','Calibrate Screen','Tag','calibrateDPI',...
    'MenuBar','none','Toolbar','none',...
    'IntegerHandle','off',...
    'Units','pixels','Visible','off');

apply=local_uicontrol('Style','pushbutton','String','Apply',...
    'Callback',@apply_callback);
    function DPI=apply_callback(varargin)
        value=get(actual,'String');
        value=sscanf(value,'%g',1);
        if isempty(value)
            errordlg('Unable to read width value');
            DPI=[];
            return
        end
        position=get(fig,'Position');
        if get(inches,'Value')
            DPI=position(3)/value;
        elseif get(centimeters,'Value')
            DPI=position(3)/(value/2.54);
        end       
        set(0,'ScreenPixelsPerInch',DPI);
        fprintf('Calibrated DPI value is %.1f\n',DPI);        
        update_width;
        %storeDPI(DPI);        
    end
locate(apply);
close=local_uicontrol('Style','pushbutton','String','Close',...
    'Callback',@close_callback);
    function close_callback(varargin)
        delete(fig);
    end
locate(close,'right',apply);

label=sprintf('%s',repmat('M',[1 6]));
actual=local_uicontrol('Style','edit','String',label);
set(actual,'String','');
locate(actual,'above',apply);
inches=local_uicontrol('Style','radiobutton','String','inches',...
    'Callback',@select_units,'Value',1);
locate(inches,'right',actual);
centimeters=local_uicontrol('Style','radiobutton','String','centimeters',...
    'Callback',@select_units,'Value',0);
locate(centimeters,'right',inches);
    function select_units(src,varargin)
        set([inches centimeters],'Value',0);
        set(src,'Value',1);
        update_width;
    end

label=sprintf('Adjust to a convenient size and enter the actual width below.');
question=local_uicontrol('Style','text','String',label,...
    'HorizontalAlignment','left');
locate(question,'above',actual);

label=sprintf('MATLAB thinks this figure is %s inches wide',repmat('M',[1 6]));
current=local_uicontrol('Style','text','String',label,...
    'HorizontalAlignment','left');
locate(current,'above',question);
    function update_width()
        if get(inches,'Value')>0
            set(fig,'Units','inches');
            position=get(fig,'Position');
            width=sprintf('%.2f inches',position(3));
        elseif get(centimeters,'Value')>0
            set(fig,'Units','centimeters');
            position=get(fig,'Position');
            width=sprintf('%.1f cm',position(3));
        end       
        set(fig,'Units','pixels');
        label=sprintf('MATLAB thinks this figure is %s wide',width);    
        set(current,'String',label);
    end

%%
resize;
set(fig,'ResizeFcn',@resize);
    function resize(varargin)
        % enforce size restraints
        fig_position=get(fig,'Position');
        hc=findobj(fig,'Type','uicontrol');
        xmax=0;
        ymax=0;
        for n=1:numel(hc)
            position=get(hc(n),'Position');            
            style=get(hc,'Style');
            if strcmpi(style,'text');
                extent=get(hc(n),'Extent');
                xmax=max(xmax,position(1)+extent(3));
            else
                xmax=max(xmax,position(1)+position(3));
            end
            ymax=max(ymax,position(2)+position(4));
        end
        fig_position(3)=max(fig_position(3),xmax);
        Ly=ymax;
        fig_position(2)=fig_position(2)+(fig_position(4)-Ly);
        fig_position(4)=Ly;
        set(fig,'Position',fig_position);
        update_width;
    end

movegui(fig,'center');
set(fig,'Visible','on','HandleVisibility','callback');

%%
set(fig,'KeyPressFcn',@keypress);
    function keypress(~,eventdata)
        position=get(fig,'Position');
        switch lower(eventdata.Key)
            case {'leftarrow','-'}
                if position(3)>1
                    position(3)=position(3)-1;
                end                
            case {'rightarrow','+'}
                position(3)=position(3)+1;
        end
        set(fig,'Position',position);
    end

end

%%
function h=local_uicontrol(varargin)

% create uicontrol
h=uicontrol(varargin{:});
set(h,'Units','pixels');

% probe monitor size
MonitorPosition=get(0,'ScreenSize');

% set uicontrol font and resize
height=MonitorPosition(4)*0.015;
set(h,'FontUnits','pixels','FontSize',height);

label=get(h,'String');
temp=repmat('M',size(label));
set(h,'String',temp);
position=get(h,'Position');
extent=get(h,'Extent');
position(3)=extent(3);
position(4)=extent(4)*1.50;
set(h,'Position',position);
set(h,'String',label);

% shrink text boxes
style=get(h,'Style');
if strcmpi(style,'text')
    extent=get(h,'Extent');
    position=get(h,'Position');
    position(3)=extent(3);
    set(h,'Position',position);
end

% match text background color to parent
parent=get(h,'Parent');
switch get(parent,'Type')
    case 'figure'
        color=get(parent,'Color');
    case 'uipanel'
        color=get(parent,'BackgroundColor');
end
if strcmpi(style,'text') || strcmp(style,'radiobutton');
    set(h,'BackgroundColor',color);
end

end

%%
function locate(current,direction,previous)

xgap=10; % pixels
ygap=10; % pixels
persistent x0 y0 

if nargin==1 % initialize
    position=get(current,'Position');
    x0=position(1);
    y0=position(2);
    return
end

position=get(previous,'Position');
switch lower(direction)
    case 'right'
        x0=position(1)+position(3)+xgap;
        y0=position(2);
    case 'above'
        x0=position(1);
        y0=position(2)+position(4)+ygap;
end
position=get(current,'Position');
position(1:2)=[x0 y0];
set(current,'Position',position);

end