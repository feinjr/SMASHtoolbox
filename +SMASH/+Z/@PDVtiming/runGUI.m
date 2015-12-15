function runGUI(object)

%% see if dialog already exists
if ishandle(object.DialogHandle)
    figure(object.DialogHandle);
    return
end

%% create dialog
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
object.DialogHandle=dlg.Handle;
dlg.Name='PDV timing analysis';

hm=uimenu(dlg.Handle,'Label','Session');
hsub=uimenu(hm,'Label','Load previous');
hsub=uimenu(hm,'Label','Save current');
hsub=uimenu(hm,'Label','Exit');

hm=uimenu(dlg.Handle,'Label','System');
hsub=uimenu(hm,'Label','General setup');
hsub=uimenu(hm,'Label','Digitizer delays');
hsub=uimenu(hm,'Label','Diagnostic delays');

label={'Define connections' 'Locate triggers' 'Measure probes'};
dummy=repmat('M',[1 max(cellfun(@numel,label))]);

%%
h=addblock(dlg,'edit','Experiment name:');
set(h(end),'String',object.Experiment,'UserData',object.Experiment,...
    'Callback',@changeName);
    function changeName(src,varargin)
        temp=strtrim(get(src,'String'));
        if isempty(temp)
            temp=get(src,'UserData');
        end
        object.Experiment=temp;
        set(src,'String',temp,'UserData',temp);
    end

h=addblock(dlg,'button',dummy);
set(h,'String',label{1},'Callback',{@connectionDialog,object})

h=addblock(dlg,'button',dummy);
set(h,'String',label{2},'Callback',{@triggerDialog,object})

h=addblock(dlg,'button',dummy);
set(h,'String',label{3},'Callback',{@probeDialog,object});

%%
dlg.Hidden=false;

end

%%
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

%%
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

%%
function probeDialog()

end