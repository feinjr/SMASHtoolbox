function DialogTrigger(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Digitizer triggers';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

hTable=addblock(dlg,'table',{'Digitizer' 'Delay (ns)'},[0 12],10);
N=numel(object.Digitizer);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.Digitizer(n));
   data{n,2}=sprintf('%.3f',object.DigitizerTrigger(n));
end
set(hTable(end),'CellEditCallback',@readTableDouble,...
    'ColumnEditable',[false true],...
    'ColumnFormat',{'char' 'char'},...
    'Data',data);    

h=addblock(dlg,'button','Measure trigger');
set(h,'Callback',{@measureTrigger,object,hTable(end)});

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        delay=nan(size(object.DigitizerTrigger));
        for k=1:numel(delay)
            delay(k)=sscanf(value{1}{k,2},'%g');
        end
        object.DigitizerTrigger=delay;
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

function measureTrigger(~,~,object,table)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Measure digitizer triggers';

width=40;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

N=numel(object.Digitizer);
label=cell(N,1);
for n=1:N
    label{n}=sprintf('%d',object.Digitizer(n));
end
hDigitizer=addblock(dlg,'popup','Digitizer:',label);

hMeasurement=addblock(dlg,'edit_button',...
    {'Measurement file:',' Select '},width);
set(hMeasurement,'TooltipString','Output trigger on machine time');
set(hMeasurement(3),'Callback',@selectFile);
    function selectFile(varargin)
        [filename,pathname]=uigetfile('*.*','Select measurement file');
        if isnumeric(filename)
            return
        end
        set(hMeasurement(2),'String',fullfile(pathname,filename));
    end

%hOffset=addblock(dlg,'edit','Offset (ns):',10);
%set(hOffset,'TooltipString','Cable delay');
%set(hOffset(2),'String','0','UserData','0',...
%    'Callback',@readEditDouble);

hDelay=addblock(dlg,'edit_button',{'Trigger (ns):' ' Calculate '},20);
set(hDelay(2),'Enable','off');
set(hDelay(3),'Callback',@calculateDelay);
    function calculateDelay(varargin)
        filename=get(hMeasurement(2),'String');
        if isempty(filename)
            return
        end
        %offset=sscanf(get(hOffset(2),'String'),'%g');
        index=get(hDigitizer(2),'Value');
        value=get(hDigitizer(2),'String');
        record=sscanf(value{index},'%d');
        record=sprintf('DM_PDV%d',record);
        delay=characterizeTrigger(object,filename,record);
        set(hDelay(2),'String',sprintf('%.3f',delay));
    end

hButton=addblock(dlg,'button',{' Apply ' ' Done '});
set(hButton(1),'Callback',@apply);
    function apply(varargin)
        delay=get(hDelay(2),'String');
        if isempty(sscanf(delay,'%g'))
            return
        end        
        index=get(hDigitizer(2),'Value');    
        data=get(table,'Data');
        for row=1:size(data,1)
            temp=sscanf(data{row,1},'%d');
            if temp==index
                data{row,2}=delay;
                break
            end
        end
        set(table,'Data',data);
    end
set(hButton(2),'Callback',@done)
    function done(varargin)
        delete(dlg);
    end

locate(dlg,'center',object.DialogHandle);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);

figure(ancestor(table,'figure'));

end