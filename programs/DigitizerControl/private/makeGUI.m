function fig=makeGUI(fontsize)

Nchannel=4;

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
for k=1:Nchannel
    ChannelLine(k)=line('Parent',fig.Axes,'Visible','off'); %#ok<AGROW>
    if k==1        
        ChannelLine=repmat(ChannelLine,4,1);           
    end
    set(ChannelLine(k),'Tag',sprintf('Channel%d',k));
end
xlabel(fig.Axes,'Time (s)');
ylabel(fig.Axes,'Signal (V)');

h=findobj(gcf,'Type','uitoggletool','Tag','standard');
set(h,'Enable','off');

hm=uimenu(fig.Figure,'Label','Program');
uimenu(hm,'Label','Select digitizers','Callback',@menuSelectDigitizers)
    function menuSelectDigitizers(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        dig=selectDigitizers(fig,dig,fontsize);        
    end

uimenu(hm,'Label','Save configuration','Separator','on');
uimenu(hm,'Label','Load configuration');
uimenu(hm,'Label','Pull calibrations','Separator','on');
uimenu(hm,'Label','Push calibrations');
uimenu(hm,'Label','Exit','Separator','on');

hm=uimenu(fig.Figure,'Label','Lock','Tag','LockMenu');
MenuLockControls=uimenu(hm,'Label','Lock digitizer controls',...
    'Tag','LockControls','Callback',@lockControls);
    function lockControls(varargin)
        if strcmpi(get(MenuLockControls,'Checked'),'off')
            lock(dig);
            set(MenuLockControls,'Checked','on');
        else
            unlock(dig);
            set(MenuLockControls,'Checked','off');
        end        
    end
MenuLockScreens=uimenu(hm,'Label','Lock digitizer screens',...
    'Tag','LockScreens','Callback',@lockScreens);
    function lockScreens(varargin)
        if strcmpi(get(MenuLockScreens,'Checked'),'off')
            lock(dig,'gui');
            set(MenuLockScreens,'Checked','on');
        else
            unlock(dig,'gui');
            set(MenuLockScreens,'Checked','off');
        end
    end
uimenu(hm,'Label','Unlock digitizers','Separator','on',...
    'Tag','Unlock','Callback',@unlock);
    function unlock(varargin)
        set(MenuLockControls,'Checked','off');
        set(MenuLockScreens,'Checked','off');
        unlock(dig);
    end

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
        index=get(digitizer(2),'Value');
        result=grab(dig(index));
        kk=0;
        for nn=1:Nchannel
            if dig(index).Channel(nn)
                kk=kk+1;
                set(ChannelLine(nn),'Visible','on',...
                    'XData',result.Grid,'YData',result.Data(:,kk))
            else
                set(ChannelLine(nn),'Visible','off');
            end
        end
    end

common=addblock(fig,'check',' Apply settings to all');

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
    'ColumnFormat',{'char' 'char'},...
    'ColumnEditable',[false true],...
    'CellEditCallback',@changeSetting)
    function changeSetting(~,EventData)
        if get(common,'Value')
            index=1:numel(get(digitizer(2),'String'));          
        else
            index=get(digitizer(2),'Value');
        end
        row=EventData.Indices(1);
        value=EventData.EditData;
        attemptSetting(dig(index),row,value);        
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
    'ColumnEditable',[false true true true true],...
    'CellEditCallback',@changeChannel)
    function changeChannel(~,EventData)
        index=1:numel(get(digitizer(2),'String'));
        row=EventData.Indices(1);
        ch=EventData.Indices(2)-1;        
        attemptChannel(dig(index),row,ch,value);
    end

arm=addblock(fig,'toggle',{' Run ' ' Single ' ' Stop '});
set(arm(1),'Callback',@runMode);
    function runMode(varargin)
        set(arm(1),'Value',1);
        set(arm(2:3),'Value',0);
        if numel(dig) > 0
            arm(dig,'run');
        end
    end
set(arm(2),'Callback',@singleMode)
    function singleMode(varargin)
        set(arm(2),'Value',1);
        set(arm([1 3]),'Value',0);
        if numel(dig) > 0
        arm(dig,'single');
        end
    end
set(arm(3),'Callback',@stopMode)
    function stopMode(varargin)        
        set(arm(3),'Value',1);
        set(arm(1:2),'Value',0);
        if numel(dig) > 0
            arm(dig,'stop');
        end
    end
stopMode();

override=addblock(fig,'button',{'Clear screens' 'Force trigger'});
set(override(1),'Callback',@clearScreens)
    function clearScreens(varargin)
        clearScreen(dig);
        set(ChannelLine,'Visible','off');
    end
set(override(2),'Callback',@forceTrigger)
    function forceTrigger(varargin)
        forceTrigger(dig);
    end

df=addblock(fig,'button','Save all data');
set(df,'Callback',@saveData)
    function saveData(varargin)
        % under construction
    end

finish(fig);
movegui(fig.Figure,'center');
fig.Hidden=false;

end

function attemptSetting(dig,row,value)

if numel(dig) > 1
    for k=1:numel(dig)
        attemptSetting(dig(k),row,value);
    end
    return
end

switch row
    case 1       
        command=sprintf('dig.Acquisition.SampleRate=%s',value);
    case 2
        command=sprintf('dig.Acquisition.NumberSamples=%s',value);        
    case 3
        command=sprintf('dig.Acquisition.NumberAverages=%s',value);              
    case 4
        command=sprintf('dig.Trigger.Source=%s',value);
    case 5
        command=sprintf('dig.Trigger.Slope=%s',value);
    case 6
        command=sprintf('dig.Trigger.Level=%s',value);
    case 7
        command=sprintf('dig.Trigger.ReferenceType=%s',value);
    case 8
        command=sprintf('dig.Trigger.ReferencePosition=%s',value);
end

try
    eval(command);
catch
    % do nothing
end

end

function attemptChannel(dig,row,ch,value) %#ok<INUSL>

switch row
    case 1
        command=sprintf('dig.Channel(%d).Scale',ch,value);
    case 2
        command=sprintf('dig.Channel(%d).Offset',ch,value);
    case 3
        if strcmpi(value,'on')
            value='1';
        elseif strcmpi(value,'off')
            value='0';
        end
        command=sprintf('dig.Channel(%d).Display',ch,value);
end

try
    eval(command);
catch
    % do nothing
end

end