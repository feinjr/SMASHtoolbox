function fig=makeGUI(fontsize)

h=findall(0,'Tag','DigitizerControl');
if ishandle(h)
    figure(h);
    return
end

dig=[];

fig=SMASH.MUI.DialogPlot('FontSize',fontsize);
fig.Hidden=true;
fig.Name='Digitizer control';
fig.Figure.Tag='DigitizerControl';

set(fig.Axes,'FontSize',fontsize);
xlabel(fig.Axes,'Time (s)');
ylabel(fig.Axes,'Signal (V)');

h=findobj(gcf,'Type','uitoggletool','Tag','standard');
set(h,'Enable','off');

hm=uimenu(fig.Figure,'Label','Program');
uimenu(hm,'Label','Select digitizers','Callback',@menuSelectDigitizers)
    function menuSelectDigitizers(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        selectDigitizers(fig,dig,fontsize);
    end

uimenu(hm,'Label','Save configuration','Separator','on');
uimenu(hm,'Label','Load configuration');
uimenu(hm,'Label','Pull calibrations','Separator','on');
uimenu(hm,'Label','Push calibrations');
uimenu(hm,'Label','Exit','Separator','on');

hm=uimenu(fig.Figure,'Label','Lock');
uimenu(hm,'Label','Lock digitizer controls');
uimenu(hm,'Label','Lock digitizer screens');
uimenu(hm,'Label','Unlock digitizers','Separator','on');

hm=uimenu(fig.Figure,'Label','Analysis');
uimenu(hm,'Label','Frequency spectrum');
uimenu(hm,'Label','Time-frequency spectrogram');

digitizer=addblock(fig,'popup_button',{'Current digitizer:' ' Read '},...
    {''},20);
set(digitizer(1),'FontWeight','bold');
setappdata(fig.ControlPanel,'DigitizerPopup',digitizer(2));
set(digitizer(end),'Callback',@readDigitizer);
    function readDigitizer(varargin)
        updateControls(fig);
    end

common=addblock(fig,'check','Common digitizer settings');

%acquire=addblock(fig,'table',{'Settings:' ' '},[20 10],3);
acquire=addblock(fig,'table',{'Settings:' ' '},[20 10],8);
set(acquire(1),'FontWeight','bold');
setappdata(fig.ControlPanel,'SettingsTable',acquire(end));
data=cell(8,2);
data{1,1}='Sample rate (1/s) :';
data{2,1}='Number samples :';
data{3,1}='Number averages :';
data{4,1}='Trigger source :';
data{5,1}='Trigger slope :';
data{6,1}='Trigger level (V) :';
data{7,1}='Reference type :';
data{8,1}='Reference position (s) :';
set(acquire(end),'Data',data,...
    'ColumnFormat',{'char' 'char'},'ColumnEditable',[false true]);
set(acquire(end),'CellEditCallback',@changeSetting);
    function changeSetting(~,EventData)
        index=get(digitizer(2),'Value');
        dig=getappdata(fig.Figure,'DigitizerObject');
        row=EventData.Indices(1);
        value=EventData.EditData;
        switch row
            case 1
                value=sscanf(value,'%g',1);
                try
                    dig(index).Acquisition.SampleRate=value;
                catch                    
                end
            case 2
                dig(index).Acquisition.NumberSamples=sscanf(value,'%d',1);  
            case 3
                dig(index).Acquisition.SampleAverages=sscanf(value,'%d',1);                                
            case 4
                
            case 5
            case 6
            case 7
            case 8
        end
        updateControls(fig);
    end

channel=addblock(fig,'table',{'Channels:' '1' '2' '3' '4'},[10 5 5 5 5],3);
set(channel(1),'Fontweight','bold');
setappdata(fig.ControlPanel,'ChannelTable',channel(end));
data=cell(3,5);
data{1,1}='Scale (V/div) :';
data{2,1}='Offset (V) :';
data{3,1}='Status :';
set(channel(end),'Data',data,...
    'ColumnFormat',{'char' 'char' 'char' 'char' 'char'},...
    'ColumnEditable',[false true true true true])

button=addblock(fig,'button',{' Run ' ' Single ' ' Stop '});
set(button(1:2),'Style','toggle');

button=addblock(fig,'button',{'Clear screens' 'Force trigger'});

df=addblock(fig,'edit_button',{'Base file name:' ' Save data '},[20 5]);
set(df(1),'FontWeight','bold');

finish(fig);
movegui(fig.Figure,'center');
fig.Hidden=false;

end