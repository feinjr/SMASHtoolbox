function updateControls(fig,dig)

popup=getappdata(fig.ControlPanel,'DigitizerPopup');

if nargin < 2
    dig=getappdata(fig.Figure,'DigitizerObject');
else
    label=cell(size(dig));
    for n=1:numel(dig)
        label{n}=dig(n).Name;
    end
    set(popup,'String',label,'Value',1);
    setappdata(fig.Figure,'DigitizerObject',dig);
end

% determined selected digitizer
index=get(popup,'Value');
dig=dig(index);

% update settings
settings=getappdata(fig.ControlPanel,'SettingsTable');
data=get(settings,'Data');

data{1,2}=sprintf('%g',dig.Acquisition.SampleRate);
data{2,2}=sprintf('%g',dig.Acquisition.NumberPoints);
data{3,2}=sprintf('%g',dig.Acquisition.NumberAverages);
data{4,2}=dig.Trigger.Source;
data{5,2}=dig.Trigger.Slope;
data{6,2}=sprintf('%g',dig.Trigger.Level);
data{7,2}=dig.Trigger.ReferenceType;
data{8,2}=dig.Trigger.ReferencePosition;

set(settings,'Data',data);

% update channels
channel=getappdata(fig.ControlPanel,'ChannelTable');
data=get(channel,'Data');

for n=1:numel(dig.Channel)
    data{1,n+1}=sprintf('%g',dig.Channel(n).Scale);
    data{2,n+1}=sprintf('%g',dig.Channel(n).Offset);
    if dig.Channel(n).Display
        data{3,n+1}='ON';
    else
        data{3,n+1}='OFF';
    end
end

set(channel,'Data',data);


end