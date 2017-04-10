function object=pickTimes(object,varargin)

if nargin == 1
    SignalNumber = size(object.Settings,2)-1;
    Signals = 1:SignalNumber;
else
    Signals = varargin{1};
end

cmap = colormap(lines);

for i = Signals
    num = object.Settings(10,i+1);
    NoiseLimits = cell2mat(num{1,1});
    int = object.Settings(11,i+1);
    IntegrationLimits = cell2mat(int{1,1});
    if isempty(NoiseLimits); NoiseLimits = [NaN, NaN]; end;
    if isempty(IntegrationLimits); IntegrationLimits = [NaN, NaN]; end;
    
%Generate the figure object
fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'pickTimes GUI';
set(fig.Handle,'Tag','pickTimesGUI');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
% set(fig.Handle,'Toolbar','figure');
ax1=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0.1 0.1 0.8 0.8]);
ylabel('Signal');
xlabel('Time');

% create Times menu
hm=uimenu(fig.Handle,'Label','Times');
uimenu(hm,'Label','Select Noise Limits','Callback',@SelectNoise);
uimenu(hm,'Label','Select Integration Limits','Callback',@SelectIntegration);
uimenu(hm,'Label','Save Limits','Callback',@SaveTimes);

        line(object.RawSignal.Grid,object.RawSignal.Data(:,i),'Color',cmap(i,:));
    

y = get(ax1,'YLim');

hN1 = line([NoiseLimits(1), NoiseLimits(1)],y,'Color','k');
hN2 = line([NoiseLimits(2), NoiseLimits(2)],y,'Color','k');

hI1 = line([IntegrationLimits(1), IntegrationLimits(1)],y,'Color','m');
hI2 = line([IntegrationLimits(2), IntegrationLimits(2)],y,'Color','m');

fig.Hidden = false;

waitfor(fig.Handle)
output1=NoiseLimits
output2=IntegrationLimits
object.Settings{10,i+1}= num2cell(NoiseLimits);
object.Settings{11,i+1}= num2cell(IntegrationLimits);

% Find baseline based on average of signal using NoiseLimits

[~,BaselineIndex1]=min(abs(NoiseLimits(1)-object.RawSignal.Grid));
[~,BaselineIndex2]=min(abs(NoiseLimits(2)-object.RawSignal.Grid));

Baseline = mean(object.RawSignal.Data(BaselineIndex1:BaselineIndex2,i));
object.Settings(12,i+1) = num2cell(Baseline);

%% Calculate noise RMS
if isempty(object.Settings(12,i+1));
    
else

BaselineData = object.RawSignal.Data(:,i)-Baseline;
BaselineData = BaselineData(BaselineIndex1:BaselineIndex2);
BaselineData = BaselineData(~isnan(BaselineData)); %Remove NAN from data
RMS = sqrt((sum(BaselineData.^2))/size(BaselineData,1));
object.Settings(13,i+1) = num2cell(RMS);

end
end

% Apply time limits to signals defined by 3rd input argument
if nargin == 3
ReferenceSignal = varargin{1}    
NewSignals = varargin{2}

     [object.Settings{10,NewSignals+1}] = deal(object.Settings{10,ReferenceSignal+1})
     [object.Settings{11,NewSignals+1}] = deal(object.Settings{11,ReferenceSignal+1})
     
for i=NewSignals     
     object.Settings{12,i+1} = mean(object.RawSignal.Data(BaselineIndex1:BaselineIndex2,i));
     
     BaselineData = object.RawSignal.Data(:,i)-object.Settings{12,i+1};
     BaselineData = BaselineData(BaselineIndex1:BaselineIndex2);
     BaselineData = BaselineData(~isnan(BaselineData)); %Remove NAN from data
     RMS = sqrt((sum(BaselineData.^2))/size(BaselineData,1));
     object.Settings(13,i+1) = num2cell(RMS);
end     
%assignin('base','test',NewSignals)
else
end

%% Callbacks

    function SelectNoise(src,varargin)
        
        axes(ax1);
        y = get(ax1,'YLim');
        [xw, ~] = ginput(2);
        set(hN1,'XData',[xw(1) xw(1)]);
        set(hN2,'XData',[xw(2) xw(2)]);
        
        NoiseLimits = xw';
        
    end
    function SelectIntegration(src,varargin)
        
        axes(ax1);
        y = get(ax1,'YLim');
        [xw, ~] = ginput(2);
        set(hI1,'XData',[xw(1) xw(1)]);
        set(hI2,'XData',[xw(2) xw(2)]);
        
        IntegrationLimits = xw';
        
    end

    function SaveTimes(src,varargin)
        NoiseLimits = sort(NoiseLimits);
        IntegrationLimits = sort(IntegrationLimits);
        close(fig.Handle)
    end

end
