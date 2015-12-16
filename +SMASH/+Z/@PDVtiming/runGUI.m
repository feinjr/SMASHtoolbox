%

%%
function runGUI(object)

% make sure label is unique
fig=findall(0,'Type','figure','Tag','SMASH:PDVtiming');
for n=1:numel(fig)
    h=findall(fig(n),'Tag','ExperimentName');
    name=get(h,'String');
    if strcmp(name,object.Experiment)
        message{1}='ERROR: conflicting experiment labels detected.';
        message{2}='       Resolve conflict and try again.';
        error('%s\n',message{:});
    end
end

% create dialog
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='PDV timing analysis';
set(dlg.Handle,'Tag','SMASH:PDVtiming');
object.DialogHandle=dlg.Handle;

% create menus
hm=uimenu(dlg.Handle,'Label','Program');
hsub=uimenu(hm,'Label','Load previous session');
set(hsub,'Callback',@(~,~) loadSession(object));
hsub=uimenu(hm,'Label','Save current session');
set(hsub,'Callback',@(~,~) saveSession(object));
hsub=uimenu(hm,'Label','Exit','Separator','on');
set(hsub,'Callback',@exitProgram);
    function exitProgram(varargin)
        choice=questdlg('Exit program?','Exit',' Yes ',' No ',' No ');
        if strcmp(choice,' Yes ')
            delete(dlg.Handle);
        end
    end
set(dlg.Handle,'CloseRequestFcn',@exitProgram);

hm=uimenu(dlg.Handle,'Label','Settings');
uimenu(hm,'Label','System setup',...
    'Callback',{@setSystem,object});
uimenu(hm,'Label','Digitizer delays',...
    'Callback',{@setDigitizerDelays,object});
uimenu(hm,'Label','Diagnostic delays',...
    'Callback',{@setDiagnosticDelays,object});
uimenu(hm,'Label','Analysis parameters',...
    'Callback',{@setAnalysisParameters,object});
uimenu(hm,'Label','OBR reference times');

hm=uimenu(dlg.Handle,'Label','Help');
hsub=uimenu(hm,'Label','Timing corrections','Enable','off');
hsub=uimenu(hm,'Label','Analysis overview','Enable','off');

label={'Define connections' 'Locate triggers' 'Measure probes' 'Analyze'};
dummy=repmat('M',[1 max(cellfun(@numel,label))]);

%
h=addblock(dlg,'edit_button',{'Experiment:' ' Comments '},[20 0]);
set(h(2),'String',object.Experiment,'UserData',object.Experiment,...
    'Tag','ExperimentName','Callback',@changeName);
    function changeName(src,varargin)
        temp=strtrim(get(src,'String'));
        if isempty(temp)
            temp=get(src,'UserData');
        end
        object.Experiment=temp;
        set(src,'String',temp,'UserData',temp);
    end
set(h(3),'Callback',@setComment);
    function setComment(varargin)
        object=comment(object);
    end

h=addblock(dlg,'button',dummy);
set(h,'String',label{1},'Callback',{@connectionDialog,object})

h=addblock(dlg,'button',dummy);
set(h,'String',label{2},'Callback',{@triggerDialog,object})

h=addblock(dlg,'button',dummy);
set(h,'String',label{3},'Callback',{@probeDialog,object});

%
locate(dlg,'center');
dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback');

end

%% menu callbacks
function setSystem(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='System setup';

label={'Experiment:' 'Probes:' 'Diagnostic channels:' 'Digitizers:'};
width=max(cellfun(@numel,label));
width=max(width,numel(object.Experiment));
width=max(width,30);

addblock(dlg,'text',label{1},width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'edit',label{2},width);
value=sprintf('%d ',object.Probe);
set(h(end),'Callback',@readEditBoxIntegers,'String',value,'UserData',value);
    
h=addblock(dlg,'edit',label{3},width);
value=sprintf('%d ',object.Diagnostic);
set(h(end),'Callback',@readEditBoxIntegers,'String',value,'UserData',value);    

h=addblock(dlg,'edit',label{4},width);
value=sprintf('%d ',object.Digitizer);
set(h(end),'Callback',@readEditBoxIntegers,'String',value,'UserData',value);    

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        object.Probe=sscanf(value{1},'%d');
        object.Diagnostic=sscanf(value{2},'%d');
        object.Digitizer=sscanf(value{3},'%d');
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

end

function setDigitizerDelays(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Digitizer delays';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'table',{'Digitizer' 'Delay (ns)'},[0 12],10);
N=numel(object.Digitizer);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.Digitizer(n));
   data{n,2}=sprintf('%.3f',object.DigitizerDelay(n));
end
set(h(end),'CellEditCallback',@readTableDouble,...
    'ColumnEditable',[false true],...
    'ColumnFormat',{'char' 'char'},...
    'Data',data);    

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        delay=nan(size(object.DigitizerDelay));
        for k=1:numel(delay)
            delay(k)=sscanf(value{1}{k,2},'%g');
        end
        object.DigitizerDelay=delay;
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

end

function setDiagnosticDelays(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Diagnostic delays';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'table',{'Diagnostic' 'Delay (ns)'},[0 12],10);
N=numel(object.Diagnostic);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.Diagnostic(n));
   data{n,2}=sprintf('%.3f',object.DiagnosticDelay(n));
end
set(h(end),'CellEditCallback',@readTableDouble,...
    'ColumnEditable',[false true],...
    'ColumnFormat',{'char' 'char'},...
    'Data',data);    

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        delay=nan(size(object.DiagnosticDelay));
        for k=1:numel(delay)
            delay(k)=sscanf(value{1}{k,2},'%g');
        end
        object.DiagnosticDelay=delay;
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

end

function setAnalysisParameters(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Diagnostic delays';

addblock(dlg,'text','Experiment:',30);
addblock(dlg,'text',['   ' object.Experiment],30);

label={...
    'Digitizer scaling (ns):' 'Derivative smoothing (ns)' ...
    'Fiducial range (ns)' 'OBR width (ns):'};
width=max(cellfun(@numel,label));

h=addblock(dlg,'edit',label{1},width);

h=addblock(dlg,'edit',label{2},width);

h=addblock(dlg,'edit',label{3},width);

h=addblock(dlg,'edit',label{4},width);

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);        
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
%dlg.Modal=true;
%uiwait(dlg.Handle);

end

function setOBRreferences(~,~,object)

% UNDER CONSTRUCTION

end

%% control callbacks
function connectionDialog(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name=sprintf('%s connections',object.Experiment);

h=addblock(dlg,'table',...
    {'DIG' 'CH' 'PDV' 'PN' 'Measurement'},...
    [5 5 5 5 20],10);
set(h(1),'TooltipString','Digitizer number');
set(h(2),'TooltipString','Digitizer channel');
set(h(3),'TooltipString','Diagnostic channel');
set(h(4),'TooltipString','Probe number')
set(h(5),'TooltipString','Measurement label')

ColumnFormat=cell(1,5);
N=numel(object.Digitizer);
ColumnFormat{1}=cell(1,N+1); % Digitizer number
for n=1:N
    ColumnFormat{1}{n}=sprintf('%d',object.Digitizer(n));
end
ColumnFormat{1}{end}=' ';
N=numel(object.DigitizerChannel);
ColumnFormat{2}=cell(1,N+1); % Digitizer channel
for n=1:N
    ColumnFormat{2}{n}=sprintf('%d',object.DigitizerChannel(n));
end
ColumnFormat{2}{end}=' ';
N=numel(object.Diagnostic);
ColumnFormat{3}=cell(1,N+1);
for n=1:N
    ColumnFormat{3}{n}=sprintf('%d',object.Diagnostic(n));
end
ColumnFormat{3}{end}=' ';
ColumnFormat{4}=ColumnFormat{3};
ColumnFormat{5}='char';
set(h(6),'ColumnFormat',ColumnFormat);

h=addblock(dlg,'Button',{' Verify ' ' Done'});

dlg.Hidden=false;

end

function triggerDialog(~,~,object)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name=sprintf('%s triggering',object.Experiment);

h=addblock(dlg,'table',...
    {'DIG' 'Trigger'},...
    [5 10],10);
set(h(1),'TooltipString','Digitizer number');
set(h(2),'TooltipString','Trigger time');



dlg.Hidden=false;

end

function probeDialog()

end

%% utilities
function readEditBoxIntegers(src,~)

value=get(src,'String');
try
    value=eval(sprintf('[%s]',value));
    assert(all(value==round(value)),'ERROR');    
    value=sprintf('%d ',value);
catch
    value=get(src,'UserData');
end
set(src,'String',value,'UserData',value);

end

function readTableDouble(src,eventdata)

data=get(src,'Data');
row=eventdata.Indices(1);
column=eventdata.Indices(2);

value=sscanf(eventdata.EditData,'%g',1);
if numel(value)==1
    data{row,column}=sprintf('%.3f',value);
else    
    data{row,column}=eventdata.PreviousData;
end

set(src,'Data',data);

end
