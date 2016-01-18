function DialogSystem(~,~,object)

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
set(h(end),'Callback',@readEditIntegers,'String',value,'UserData',value);
    
h=addblock(dlg,'edit',label{3},width);
value=sprintf('%d ',object.Diagnostic);
set(h(end),'Callback',@readEditIntegers,'String',value,'UserData',value);    

h=addblock(dlg,'edit',label{4},width);
value=sprintf('%d ',object.Digitizer);
set(h(end),'Callback',@readEditIntegers,'String',value,'UserData',value);    

hConfig=addblock(dlg,'button',' Configure digitizer(s)');
set(hConfig,'Callback',{@configureDigitizers,object,dlg});
setappdata(hConfig,'DigitizerChannel',object.DigitizerChannel);

%h=addblock(dlg,'edit','Max. connections:');
%value=sprintf('%d',object.MaxConnections);
%set(h(end),'Callback',@readEditInteger,'String',value,'UserData',value);

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        object.Probe=sscanf(value{1},'%d');
        N=numel(object.Probe);
        if object.ProbeDelay ~= N
            object.ProbeDelay=zeros(1,N);
        end
        object.Diagnostic=sscanf(value{2},'%d');
        N=numel(object.Diagnostic);
        if numel(object.DiagnosticDelay) ~= N
            object.DiagnosticDelay=zeros(1,N);
        end
        object.Digitizer=sscanf(value{3},'%d');        
        N=numel(object.Digitizer);
        object.DigitizerChannel=getappdata(hConfig,'DigitizerChannel');
        if numel(object.DigitizerChannel) ~= N
            object.DigitizerDelay=zeros(1,N);
            object.DigitizerTrigger=zeros(1,N);
            channel=cell(N,1);
            delay=cell(N,1);
            for n=1:N
                channel{n}=1:4;
                delay{n}=zeros(1,4);
            end          
            object.DigitizerChannel=channel;
            object.DigitizerChannelDelay=delay;
        end
        %object.MaxConnections=sscanf(value{4},'%d');        
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

function configureDigitizers(src,~,object,parent)

% reconcile digitizer/channels
value=probe(parent);
Digitizer=sscanf(value{3},'%d');
N=numel(Digitizer);
DigitizerChannel=getappdata(src,'DigitizerChannel');
if numel(DigitizerChannel) ~= N
    DigitizerChannel=cell(1,N);
    for n=1:N
        DigitizerChannel{n}=1:4;
    end
end

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Digitizer channels';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'table',{'Digitizer' 'Channels'},[0 16],10);
N=numel(object.Digitizer);
data=cell(N,2);
for n=1:N
    data{n,1}=sprintf('%d',n);
    data{n,2}=sprintf('%d ',DigitizerChannel{n});
end
set(h(end),'ColumnEditable',[false true],'ColumnFormat',{'char' 'char'},...
    'Data',data,'CellEditCallback',@readTableIntegers);

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        value=value{1};
        N=numel(object.Digitizer);
        DigitizerChannel=cell(N,1);
        for nd=1:N
            temp=sscanf(value{nd,2},'%d');
            DigitizerChannel{nd}=transpose(temp);
        end   
        setappdata(src,'DigitizerChannel',DigitizerChannel);
        delete(dlg);
        figure(parent.Handle);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)   
        delete(dlg);
        figure(parent.Handle);
    end

locate(dlg,'center',parent.Handle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

end
