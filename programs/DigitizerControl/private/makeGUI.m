function fig=makeGUI(fontsize)

Nchannel=4;

h=findall(0,'Tag','DigitizerControl');
if ishandle(h)
    figure(h);
    return
end

fig=SMASH.MUI.DialogPlot('FontSize',fontsize);
fig.Hidden=true;
fig.Name='Digitizer control';
fig.Figure.Tag='DigitizerControl';

set(fig.Axes,'FontSize',fontsize);
color={'y' 'g' 'b' 'r'};
for k=1:Nchannel
    ChannelLine(k)=line('Parent',fig.Axes,'Visible','off'); %#ok<AGROW>
    if k==1        
        ChannelLine=repmat(ChannelLine,4,1);           
    end
    set(ChannelLine(k),...
        'Color',color{k},'Tag',sprintf('Channel%d',k));
end
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

hm=uimenu(fig.Figure,'Label','Lock','Tag','LockMenu');
MenuLockControls=uimenu(hm,'Label','Lock digitizer controls',...
    'Tag','LockControls','Callback',@lockControls);
    function lockControls(varargin)
        if strcmpi(get(MenuLockControls,'Checked'),'off')
            dig=getappdata(fig.Figure,'DigitizerObject');
            lock(dig);
            set(MenuLockControls,'Checked','on');
        else
            dig=getappdata(fig.Figure,'DigitizerObject');
            unlock(dig);
            set(MenuLockControls,'Checked','off');
        end        
    end
MenuLockScreens=uimenu(hm,'Label','Lock digitizer screens',...
    'Tag','LockScreens','Callback',@lockScreens);
    function lockScreens(varargin)
        if strcmpi(get(MenuLockScreens,'Checked'),'off')
            dig=getappdata(fig.Figure,'DigitizerObject');
            lock(dig,'gui');
            set(MenuLockScreens,'Checked','on');
        else
            dig=getappdata(fig.Figure,'DigitizerObject');
            unlock(dig,'gui');
            set(MenuLockScreens,'Checked','off');
        end
    end
uimenu(hm,'Label','Unlock digitizers','Separator','on',...
    'Tag','Unlock','Callback',@unlock);
    function unlock(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
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
        dig=getappdata(fig.Figure,'DigitizerObject');
        updateControls(fig);
        index=get(digitizer(2),'Value');
        result=grab(dig(index));
        kk=0;
        label=cell(size(result));
        h=nan(size(result));
        for nn=1:Nchannel
            if dig(index).Channel(nn).Display
                kk=kk+1;
                try
                    x=result.Grid;
                    y=result.Data(:,kk);
                catch
                    return
                end
                set(ChannelLine(nn),'Visible','on',...
                    'XData',x,'YData',y)
                h(kk)=ChannelLine(nn);
                label{kk}=sprintf('Channel %d',nn);
            else
                set(ChannelLine(nn),'Visible','off');
            end
        end
        if ~isempty(label)
            legend(h,label,'Location','best');
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
    function changeSetting(src,EventData)
        dig=getappdata(fig.Figure,'DigitizerObject');
        if get(common,'Value')
            index=1:numel(get(digitizer(2),'String'));          
        else
            index=get(digitizer(2),'Value');
        end
        row=EventData.Indices(1);
        column=EventData.Indices(2);
        value=EventData.EditData;       
        value=attemptSetting(dig(index),row,value);
        data=get(src,'Data');
        data{row,column}=value;
        set(src,'Data',data);
        setappdata(fig.Figure,'DigitizerObject',dig);
        %updateControls(fig);
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
        dig=getappdata(fig.Figure,'DigitizerObject');
        index=1:numel(get(digitizer(2),'String'));
        row=EventData.Indices(1);
        ch=EventData.Indices(2)-1;        
        attemptChannel(dig(index),row,ch,value);
    end

arm=addblock(fig,'toggle',{' Run ' ' Single ' ' Stop '});
set(arm(1),'Callback',@runMode);
    function runMode(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        set(arm(1),'Value',1);
        set(arm(2:3),'Value',0);
        if numel(dig) > 0
            arm(dig,'run');
        end
    end
set(arm(2),'Callback',@singleMode)
    function singleMode(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        set(arm(2),'Value',1);
        set(arm([1 3]),'Value',0);
        if numel(dig) > 0
        arm(dig,'single');
        end
    end
set(arm(3),'Callback',@stopMode)
    function stopMode(varargin) 
        dig=getappdata(fig.Figure,'DigitizerObject');
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
        dig=getappdata(fig.Figure,'DigitizerObject');
        clearScreen(dig);
        set(ChannelLine,'Visible','off');
    end
set(override(2),'Callback',@forceTrigger)
    function forceTrigger(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
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

function value=attemptSetting(dig,row,value)

if numel(dig) > 1
    for k=1:numel(dig)
        attemptSetting(dig(k),row,value);
    end
    return
end

switch row
    case 1        
        try
            dig.Acquisition.SampleRate=sscanf(value,'%g',1);
        catch
        end
        value=sprintf('%g',dig.Acquisition.SampleRate);
    case 2
        try
        dig.Acquisition.NumberPoints=sscanf(value,'%g',1);
        catch
        end
        value=sprintf('%g',dig.Acquisition.NumberPoints);
    case 3
        try
        dig.Acquisition.NumberAverages=sscanf(value,'%g',1);
        catch
        end
        value=sprintf('%g',dig.Acquisition.NumberAverages);
    case 4
        try
            dig.Trigger.Source=value;
        catch
        end
        value=dig.Trigger.Source;
    case 5
        try
            dig.Trigger.Slope=value;
        catch
        end
        value=dig.Trigger.Slope;                
    case 6
        try
            dig.Trigger.Level=sscanf(value,'%g',1);
        catch
        end
        value=dig.Trigger.Level;
    case 7
        try
            dig.Trigger.ReferenceType=value;
        catch
        end
        value=dig.Trigger.ReferenceType;
    case 8
        try
            dig.Trigger.ReferencePosition=sscanf(value,'%g',1);
        catch
        end
        value=dig.Trigger.ReferencePosition;
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