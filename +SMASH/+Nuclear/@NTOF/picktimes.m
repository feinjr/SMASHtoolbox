function object=picktimes(object)

NoiseLimits = object.Settings.NoiseLimits;
SignalLimits = object.Settings.SignalLimits;
FitLimits = object.Settings.FitLimits;
if isempty(SignalLimits); SignalLimits = [NaN, NaN]; end;
if isempty(NoiseLimits); NoiseLimits = [NaN, NaN]; end;
if isempty(FitLimits); FitLimits = [NaN, NaN]; end;

%Generate the figure object
fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'pickTimes GUI';
set(fig.Handle,'Tag','pickTimesGUI');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
set(fig.Handle,'Toolbar','figure');
ax1=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0.1 0.1 0.8 0.8]);
ylabel('Signal');
xlabel('Time')

if ~isnan(SignalLimits)
    set(ax1,'XLim',SignalLimits)
end

% create Times menu
hm=uimenu(fig.Handle,'Label','Times');
uimenu(hm,'Label','Select Signal Limits','Callback',@SelectSignal);
uimenu(hm,'Label','Select Noise Limits','Callback',@SelectNoise);
uimenu(hm,'Label','Select Fit Limits','Callback',@SelectFit);
uimenu(hm,'Label','Save Limits','Callback',@SaveTimes);

if isempty(object.Settings.FitSignal)
    Nsig = size(object.Measurement.Data,2);
    cmap = colormap(lines);
    for i = 1:Nsig
        line(object.Measurement.Grid,-1*object.Measurement.Data(:,i),'Color',cmap(i,:));
    end
else
    line(object.Measurement.Grid,-1*object.Measurement.Data(:,object.Settings.FitSignal),'Color','b'); 
end
y = get(ax1,'YLim');

hS1 = line([SignalLimits(1), SignalLimits(1)],y,'Color','b');
hS2 = line([SignalLimits(2), SignalLimits(2)],y,'Color','b');

hN1 = line([NoiseLimits(1), NoiseLimits(1)],y,'Color','k');
hN2 = line([NoiseLimits(2), NoiseLimits(2)],y,'Color','k');

hF1 = line([FitLimits(1), FitLimits(1)],y,'Color','m');
hF2 = line([FitLimits(2), FitLimits(2)],y,'Color','m');

fig.Hidden = false;

waitfor(fig.Handle)

object = configure(object,  'SignalLimits',SignalLimits,...
    'NoiseLimits',NoiseLimits,...
    'FitLimits',FitLimits);
%% Callbacks
    function SelectSignal(src,varargin)
        
        axes(ax1);
        y = get(ax1,'YLim');
        [xw, ~] = ginput(2);
        set(hS1,'XData',[xw(1) xw(1)]);
        set(hS2,'XData',[xw(2) xw(2)]);
        
        SignalLimits = xw';
        
    end
    function SelectNoise(src,varargin)
        
        axes(ax1);
        y = get(ax1,'YLim');
        [xw, ~] = ginput(2);
        set(hN1,'XData',[xw(1) xw(1)]);
        set(hN2,'XData',[xw(2) xw(2)]);
        
        NoiseLimits = xw';
        
    end
    function SelectFit(src,varargin)
        
        axes(ax1);
        y = get(ax1,'YLim');
        [xw, ~] = ginput(2);
        set(hF1,'XData',[xw(1) xw(1)]);
        set(hF2,'XData',[xw(2) xw(2)]);
        
        FitLimits = xw';
        
    end

    function SaveTimes(src,varargin)
        SignalLimits = sort(SignalLimits);
        NoiseLimits = sort(NoiseLimits);
        FitLimits = sort(FitLimits);
        close(fig.Handle)
    end

end
