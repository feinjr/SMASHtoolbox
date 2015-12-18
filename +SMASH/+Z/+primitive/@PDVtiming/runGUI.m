%

%
%
%
function runGUI(object)

%% make sure label is unique
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

%% create dialog
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='PDV timing analysis';
set(dlg.Handle,'Tag','SMASH:PDVtiming');
object.DialogHandle=dlg.Handle;

%% create menus
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
    'Callback',{@DialogSystem,object});
uimenu(hm,'Label','Analysis parameters',...
    'Callback',{@DialogAnalysisParameter,object});
uimenu(hm,'Label','Digitizer delays','Separator','on',...
    'Callback',{@DialogDigitizerDelay,object});
uimenu(hm,'Label','Diagnostic delays',...
    'Callback',{@DialogDiagnosticDelay,object});

uimenu(hm,'Label','OBR reference times',...
    'Callback',{@DialogOBRreferences,object});

hm=uimenu(dlg.Handle,'Label','Help');
uimenu(hm,'Label','Timing corrections','Enable','off');
uimenu(hm,'Label','Analysis overview','Enable','off');

%%
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

label={'Define connections' 'Locate triggers' 'Measure probes' 'Analyze'};
dummy=repmat('M',[1 max(cellfun(@numel,label))]);

h=addblock(dlg,'button',dummy);
set(h,'String',label{1},'Callback',{@DialogConnection,object})

h=addblock(dlg,'button',dummy);
set(h,'String',label{2},'Callback',{@DialogTrigger,object},'Enable','off')

h=addblock(dlg,'button',dummy);
set(h,'String',label{3},'Callback',{@DialogProbe,object},'Enable','off');

h=addblock(dlg,'button',dummy);
set(h,'String',label{4},'Callback',{@DialogAnalysis,object},'Enable','off');

%%
locate(dlg,'center');
dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback');

end