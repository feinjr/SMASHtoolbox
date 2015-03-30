% pickTimes for analyzing a VelocityTransfer object
%
% This method provides a graphical option for picking the causal times used
% when analyzing the object.
%
%     >> object=pickTimes(object);
%
% An interactive figure is displayed showing the window velocities on top
% and insitu velocities below. A measure of the accelerations are also
% shown to aid in picking out obvious causal features. There is a single
% dropdown menu 'Times' which allows for the modification of the causal
% timing. Select times brings up a graphical input from the mouse (ginput)
% allowing the user to select obvious features in the window simulation
% until 'Return' is pressed. The same number of inputs are then required
% for the simulated insitu velocity. 'Delete Times' starts over, while
% 'Save Times' closes the figure and saves the selections to the output
% object.
%
% See also VelocityTransfer, analyze
%
%
% created March 26, 2015 by Justin Brown (Sandia National Laboratories)
%
function object=pickTimes(object,varargin)

% Update object
if nargin>2;
    assert(length(varargin{1})==length(varargin{2}),'Time arrays must be same size');
    WindowTimes = varargin{1};
    InsituTimes = varargin{2}; 
else
% Create interactive figure
    WindowTimes=object.Settings.WindowTimes;
    InsituTimes=object.Settings.InsituTimes;
    maxw = max(object.SimulatedWindow.Data);
    maxi = max(object.SimulatedInsitu.Data);

    %Generate the figure object
    fig = SMASH.MUI.Figure; fig.Hidden = true;
    fig.Name = 'pickTimes GUI';
    set(fig.Handle,'Tag','pickTimesGUI');
    set(fig.Handle,'Units','normalized');
    set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
    set(fig.Handle,'Toolbar','figure');
    ax1=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0 0.5 1 0.5]);
    ylabel('Window Velocities');


    ax2=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0 0.0 1 0.5]);   
    xlabel('Time');
    ylabel('In Situ Velocities');
    linkaxes([ax1,ax2],'x');


    %% create Times menu
    hm=uimenu(fig.Handle,'Label','Times');
    uimenu(hm,'Label','Select Times','Callback',@SelectTimes);
    uimenu(hm,'Label','Delete Times','Callback',@DeleteTimes);
    uimenu(hm,'Label','Save Times','Callback',@SaveTimes);
    
    PlotVelocities('tight');
    fig.Hidden = false;

waitfor(fig.Handle)
object.Settings.WindowTimes=WindowTimes;
object.Settings.InsituTimes=InsituTimes;
end


%% Callbacks
function SelectTimes(src,varargin)
    
    %Select Window Times
    PlotVelocities('overlay');
    axes(ax1);
    [xw yp] = ginput;
    WindowTimes=[WindowTimes; xw];
    
    %Select InSitu Times
    PlotVelocities('overlay');
    axes(ax2);
    [xi yp] = ginput(length(xw));
    InsituTimes=[InsituTimes; xi];
    
    PlotVelocities('overlay');

end

function DeleteTimes(src,varargin)
    WindowTimes=[];
    InsituTimes=[];   
    PlotVelocities('tight');
end

function SaveTimes(src,varargin)
    assert(length(WindowTimes)==length(InsituTimes),'Time arrays must be same size');
    WindowTimes=sort(WindowTimes);
    InsituTimes=sort(InsituTimes);
    close(fig.Handle)
end


function PlotVelocities(mode)
    
    %Plot window velocities
    axes(ax1); cla;
    [time,value]=limit(object.MeasuredWindow);
    h=line(time,value);
    apply(object.MeasuredWindow.GraphicOptions,h);
    [time,value]=limit(object.SimulatedWindow);
    h=line(time,value);
    apply(object.SimulatedWindow.GraphicOptions,h);
    
    %Plot accelerations
    temp=object.SimulatedWindow;
    temp=regrid(temp);
    acc=differentiate(temp,[1 3],1,'zero');
    [x y]=limit(acc);
    y=abs(y); y=y./max(y).*maxw;
    h=line(x,y);
    set(h,'Color',[.6 .6 .6]);
    
    %Plot any existing Window Times
    if ~isempty(WindowTimes);
        for i=1:length(WindowTimes);
            h=line([WindowTimes(i) WindowTimes(i)],[0 maxw]);
            set(h,'Color',[1 0 0],'LineStyle','--');
        end
    end
     
    
    if strcmpi(mode,'tight')
        axis tight;
    end

    %Plot insitu velocities
    axes(ax2); cla;
    [time,value]=limit(object.SimulatedInsitu);
    h=line(time,value);
    apply(object.SimulatedInsitu.GraphicOptions,h);
    
    %Plot accleration
    temp=object.SimulatedInsitu;
    temp=regrid(temp);
    acc=differentiate(temp,[1 3],1,'zero');
    [x y]=limit(acc);
    y=abs(y); y=y./max(y).*maxi;
    h=line(x,y);
    set(h,'Color',[.6 .6 .6]);
    
    %Plot any existing InSitu Times
    if ~isempty(InsituTimes);
        for i=1:length(InsituTimes);
            h=line([InsituTimes(i) InsituTimes(i)],[0 maxi]);
            set(h,'Color',[1 0 0],'LineStyle','--');
        end
    end    
    
    if strcmpi(mode,'tight')
        axis tight;
    end
end



end


