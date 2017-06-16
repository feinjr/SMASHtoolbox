function fig=makeGUI(fontsize)

%%
h=findall(0,'Tag','DigitizerControl');
if ishandle(h)
    fprintf('Program already running...making active\n');
    figure(h);    
    return
end

Nchannel=4;
fig=SMASH.MUI.DialogPlot('FontSize',fontsize);
fig.Hidden=true;
fig.Name='Digitizer control';
fig.Figure.Tag='DigitizerControl';

set(fig.Axes,'FontSize',fontsize,'Color','k',...
    'GridColor','w','XGrid','on','YGrid','on');
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
uimenu(hm,'Label','Start over','Callback',@startOver)
    function startOver(varargin)
        list=findall(0,'Type','figure');        
        for n=1:numel(list)
            tag=get(list(n),'Tag');
            if strfind(tag,'DigitizerControl')
                delete(list(n))
            end
        end
        SMASH.Instrument.reset('Digitizer');
        makeGUI(fontsize);        
    end
uimenu(hm,'Label','Save configuration','Separator','on',...
    'Callback',@saveConfiguration);
    function saveConfiguration(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        warning('off','MATLAB:structOnObject');
        dig=struct(dig); %#ok<NASGU>
        warning('on','MATLAB:structOnObject');
        [name,location]=uiputfile('*.cfg','Save digitizer configuration');
        if isnumeric(name)
            return
        end
        name=fullfile(location,name);
        save(name,'dig','-mat');
    end
uimenu(hm,'Label','Load configuration','Callback',@loadConfiguration);
    function loadConfiguration(varargin)
        [name,location]=uigetfile('*.cfg','Save digitizer configuration');
        if isnumeric(name)
            return
        end
        name=fullfile(location,name);
        previous=load(name,'dig','-mat');
        dig=SMASH.Instrument.Digitizer(previous.dig);
        updateControls(fig,dig);               
    end
uimenu(hm,'Label','Exit','Separator','on','Callback',@exitProgram);
    function exitProgram(varargin)
        choice=questdlg('Exit Digitizer control?','Exit',' Yes ',' No ',' No ');
        if ~isnumeric(choice) && strcmpi(strtrim(choice),'yes')
            dig=getappdata(fig.Figure,'DigitizerObject');
            try
                unlock(dig);
            catch
            end
            delete(fig.Figure);            
        end        
    end
set(fig.Figure,'CloseRequestFcn',@exitProgram);

hm=uimenu(fig.Figure,'Label','Data');
uimenu(hm,'Label','Save all digitizers',...
    'Callback',@saveAll);
    function saveAll(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        saveData(fig,dig,'Save all digitizers',fontsize);
    end
uimenu(hm,'Label','Save current digitizer',...
    'Callback',@saveCurrent);
    function saveCurrent(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        current=get(digitizer(2),'Value');
        saveData(fig,dig(current),'Save current digitizer',fontsize);
    end

hm=uimenu(fig.Figure,'Label','Calibration');
uimenu(hm,'Label','Enable push/pull','Callback',@enablePushPull);
    function enablePushPull(src,~)
        temp=[pullCal pushCal];
        if get(src,'Value')
            set(temp,'Enable','on');
        else
            set(temp,'Enable','off');
        end
    end
pullCal=uimenu(hm,'Label','Pull files','Enable','off',...
    'Callback',@pullCalibration);
    function pullCalibration(varargin)
        commandwindow;
        dig=getappdata(fig.Figure,'DigitizerObject');
        start=pwd;
        CU=onCleanup(@() cd(start));
        if exist('calibration','dir')
            rmdir(fullfile(pwd,'calibration'),'s')
        end
        mkdir('calibration');
        cd calibration;
        pull(dig);
        figure(fig.Figure);        
    end
pushCal=uimenu(hm,'Label','Push files','Enable','off',...
    'Callback',@pushCalibration);
    function pushCalibration(varargin)
        message{1}='Are you sure?  This may take some time...';
        message{end+1}='DO NOT INTERRUPT THIS PROCESS ONCE STARTED!!!';
        choice=questdlg(message,'Push calibration',...
            ' yes ',' no ',' no ');
        if ~strcmpi(choice,' yes ')
            return
        end
        commandwindow;
        dig=getappdata(fig.Figure,'DigitizerObject');
        start=pwd;
        CU=onCleanup(@() cd(start));
        cd calibration;
        push(dig);
        figure(fig.Figure); 
    end
uimenu(hm,'Label','Check status','Separator','on','Callback',@checkCalibration);
    function checkCalibration(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        showCalibration(dig,fontsize);
    end

hm=uimenu(fig.Figure,'Label','Analysis');
uimenu(hm,'Label','Frequency spectra','Callback',@runFFT);
    function runFFT(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        FFTanalysis(dig,fontsize);
    end
uimenu(hm,'Label','Time-frequency spectrograms','Enable','off');

%%
digitizer=addblock(fig,'popup_button',{'Current digitizer:' ' Read '},...
    {''},20);
set(digitizer(1),'FontWeight','bold');
setappdata(fig.ControlPanel,'DigitizerPopup',digitizer(2));
set(digitizer(2),'Callback',@changeDigitizer)
    function changeDigitizer(varargin)
        updateControls(fig);
        set(ChannelLine,'Visible','off');
    end
set(digitizer(end),'Callback',@readDigitizer);
    function readDigitizer(varargin)
        WorkingButton(digitizer(end));
        CU=onCleanup(@() WorkingButton(digitizer(end)));
        dig=getappdata(fig.Figure,'DigitizerObject');
        updateControls(fig);
        index=get(digitizer(2),'Value');
        result=grab(dig(index));
        if isempty(result)
            set(ChannelLine,'Visible','off');
            return
        end
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
            legend(h,label,'Location','best','Color',repmat(0.75,[1 3]));
        end
    end

    function globalSettings(varargin)
        if get(common,'Value')
            set(acquire(1),'String','Global digitizer settings:');
        else
            set(acquire(1),'String','Current digitizer settings:');
        end
    end

acquire=addblock(fig,'table',{'Settings:' ' Global'},[20 10],7);
set(acquire(1),'FontWeight','bold');
set(acquire(2),'Style','checkbox','Callback',@globalSettings)
common=acquire(2);
globalSettings();
setappdata(fig.ControlPanel,'SettingsTable',acquire(end));
data=cell(7,2);
data{1,1}='Sample rate (1/s) :';
data{2,1}='Number samples :';
data{3,1}='Number averages :';
data{4,1}='Trigger source :';
data{5,1}='Trigger slope :';
data{6,1}='Trigger level (V) :';
%data{7,1}='Reference type :';
data{7,1}='Start time (s) :';
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
    end

%%
channel=addblock(fig,'table',{'' 'CH 1' 'CH 2' 'CH 3' 'CH 4'},[10 5 5 5 5],5);
set(channel(1:5),'Fontweight','bold');
setappdata(fig.ControlPanel,'ChannelTable',channel(end));
data=cell(5,5);
data{1,1}='Coupling :';
data{2,1}='Impedance :';
data{3,1}='Scale (V/div) :';
data{4,1}='Offset (V) :';
data{5,1}='Status :';
set(channel(end),'Data',data,...
    'ColumnFormat',{'char' 'char' 'char' 'char' 'char'},...
    'ColumnEditable',[false true true true true],...
    'CellEditCallback',@changeChannel)
    function changeChannel(src,EventData)
        dig=getappdata(fig.Figure,'DigitizerObject');
        index=get(digitizer(2),'Value');
        row=EventData.Indices(1);
        column=EventData.Indices(2);
        ch=column-1;
        value=EventData.EditData;
        value=attemptChannel(dig(index),row,ch,value);
        data=get(src,'Data');
        data{row,column}=value;
        set(src,'Data',data);
        setappdata(fig.Figure,'DigitizerObject',dig);
    end

ReadInterval=addblock(fig,'edit','Trig query (s):');
set(ReadInterval(2),'String',2,'UserData',2,'Callback',@changeInterval);
    function changeInterval(src,~)
        new=sscanf(get(src,'String'),'%g',1);
        if isempty(new)
            new=get(src,'UserData');
        end
        new=max(new,1);               
        set(src,'String',sprintf('%.2g',new),'UserData',new);
    end

arm=addblock(fig,'button',{' Run ' ' Single ' ' Stop '});
DefaultBackground=get(arm(1),'BackgroundColor');
set(arm(1),'Callback',@runMode);
    function runMode(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        if isempty(dig)
            stopMode();
            return
        end              
        set(arm(1),'BackgroundColor','g','Fontweight','bold');        
        set(arm(2:3),'BackgroundColor',DefaultBackground,...
            'Fontweight','normal');  
        for n=1:numel(dig)
            dig(n).arm('run');
        end
        setappdata(fig.Figure,'stopped',false);
        while true
            pause(get(ReadInterval(2),'UserData'));
            switch lower(dig(1).RunState)
                case 'single'
                    singleMode();
                case 'run'                    
                    try
                        readDigitizer();
                    catch
                    end
                    continue
                case 'stop'
                    stopMode();
                    drawnow();
                    break
            end
        end
    end
set(arm(2),'Callback',@singleMode)
    function singleMode(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        if get(paranoid(2),'Value')
            runParanoid(fig,dig,fontsize);
            return
        end        
        set(arm(2),'BackgroundColor','g','Fontweight','bold');
        set(arm([1 3]),'BackgroundColor',DefaultBackground,...
            'Fontweight','normal');
        if isempty(dig)
            return
        end
        for n=1:numel(dig)
            dig(n).arm('single'); % avoid confusion with variable "arm"
        end
        setappdata(fig.Figure,'Stopped',false);
        while true
           pause(get(ReadInterval(2),'UserData')); 
           switch lower(dig(1).RunState)
               case 'single'
                   continue
               case 'stop'
                   stopMode();
                   drawnow();
                   if ~getappdata(fig.Figure,'Stopped');                  
                       readDigitizer();                   
                   end
                   break
               case 'run'
                   runMode();
           end          
        end
        
    end
set(arm(3),'Callback',@stopMode)
    function stopMode(varargin) 
        dig=getappdata(fig.Figure,'DigitizerObject');
        set(arm(3),'BackgroundColor','r','FontWeight','bold');
        set(arm(1:2),'BackgroundColor',DefaultBackground,...
            'FontWeight','normal');
        for n=1:numel(dig)            
            dig(n).arm('stop');
        end
        if nargin == 2
            setappdata(fig.Figure,'Stopped',true);
        end
    end
stopMode();

override=addblock(fig,'button',{'Clear display' 'Force trigger'});
set(override(1),'Callback',@clearDisplays)
    function clearDisplays(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        clearDisplay(dig);
        set(ChannelLine,'Visible','off');
    end
set(override(2),'Callback',@forceTrigger)
    function forceTrigger(varargin)
        dig=getappdata(fig.Figure,'DigitizerObject');
        if isempty(dig)
            return
        end
        for n=1:numel(dig)
            switch lower(dig(n).RunState)
                case 'single'                    
                    dig(n).forceTrigger();
                    stopMode();
                    drawnow();
                    readDigitizer();
                case 'run'
                    dig(n).forceTrigger();
                    dig(n).arm('stop');
                    readDigitizer();
                    dig(n).arm('run');
            end
        end
    end

paranoid=addblock(fig,'checkbox',{'Lock digitizers' 'Shot mode'});
set(paranoid(1),'Callback',@lockDigitizers)
    function lockDigitizers(src,~)
        dig=getappdata(fig.Figure,'DigitizerObject');
        if get(src,'Value')
            lock(dig);
        else
            unlock(dig);
        end
    end
set(paranoid(2),'Callback',@shotMode);
    function shotMode(src,~)
        if get(src,'Value')
            set(arm(1),'Enable','off');
        else
            set(arm(1),'Enable','on');
        end
    end

%%
finish(fig);
movegui(fig.Figure,'center');
drawnow();
fig.Hidden=false;
set(fig.Figure,'HandleVisibility','callback');

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
            dig.Trigger.Start=sscanf(value,'%g',1);
        catch
        end
        value=dig.Trigger.Start;
end   

end

function value=attemptChannel(dig,row,ch,value)

switch row
    case 1
        try
            dig.Channel(ch).Coupling=value;
        catch
        end
        value=dig.Channel(ch).Coupling;
    case 2
        try
            dig.Channel(ch).Impedance=value;
        catch
        end
        value=dig.Channel(ch).Impedance;
    case 3
        try
            dig.Channel(ch).Scale=sscanf(value,'%g',1);
        catch
        end
        value=dig.Channel(ch).Scale;
    case 4
        try
            dig.Channel(ch).Offset=sscanf(value,'%g',1);
        catch
        end
        value=dig.Channel(ch).Offset;
    case 5
        if strcmpi(value,'on')
            value=true;
        elseif strcmpi(value,'off')
            value=false;
        end
        try
            dig.Channel(ch).Display=value;
        catch
        end
        value=dig.Channel(ch).Display;
        if value
            value='ON';
        else
            value='OFF';
        end
end

end