function DialogProbe(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Probe delays';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

hTable=addblock(dlg,'table',{'Probe' 'Delay (ns)'},[0 12],10);
N=numel(object.Probe);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.Probe(n));
   data{n,2}=sprintf('%.3f',object.ProbeDelay(n));
end
set(hTable(end),'CellEditCallback',@readTableDouble,...
    'ColumnEditable',[false true],...
    'ColumnFormat',{'char' 'char'},...
    'Data',data);    

h=addblock(dlg,'button','Measure delay');
set(h,'Callback',{@measureDelay,object,hTable(end)});

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        delay=nan(size(object.ProbeDelay));
        for k=1:numel(delay)
            delay(k)=sscanf(value{1}{k,2},'%g');
        end
        object.ProbeDelay=delay;
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

function measureDelay(~,~,object,table)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Measure probe delays';

width=40;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

N=numel(object.Probe);
label=cell(N,1);
for n=1:N
    label{n}=sprintf('%d',object.Probe(n));
end
hProbe=addblock(dlg,'popup','Probe:',label);

hMeasurement=addblock(dlg,'edit_button',...
    {'Measurement scan file:',' Select '},width);
hMeasurementLabel=addblock(dlg,'edit_button',{'Measurement label:' ' Change '},width);
set(hMeasurement(3),...
    'Callback',{@selectFile,hMeasurement,hMeasurementLabel});   
set(hMeasurementLabel(2:3),'Enable','off');
set(hMeasurementLabel(3),...
    'Callback',{@selectRecord,hMeasurement,hMeasurementLabel});

hSelect=addblock(dlg,'radio',{' Reference scan file ' ' OBR reference '});
hReference=addblock(dlg,'edit_button',{'',' Select '},width,'skiplabel');
hReferenceLabel=addblock(dlg,'edit_button',...
    {'Reference label:' ' Change '},width);
set(hReferenceLabel(2:3),'Enable','off');
set(hSelect(1),'Callback',@OBRfile);
    function OBRfile(varargin)
        set(hSelect(1),'Value',1);
        set(hSelect(2),'Value',0);
        set(hReference(2),'Style','edit','String','');
        set(hReference(3),'Visible','on');  
        set(hReferenceLabel(2),'String','');
        set(hReferenceLabel,'Visible','on');        
    end
set(hSelect(2),'Callback',@OBRvalue);
    function OBRvalue(varargin)
        set(hSelect(1),'Value',0);
        set(hSelect(2),'Value',1);
        N=size(object.OBRreference,1);
        choice=cell(1,N);
        for nc=1:N
            choice{nc}=sprintf('Channel %d',object.OBRreference(nc,1));
        end
        set(hReference(2),'Style','popup','String',choice);
        set(hReference(3),'Visible','off');
        set(hReferenceLabel,'Visible','off');
    end
set(hReference(3),...
    'Callback',{@selectFile,hReference,hReferenceLabel});    
set(hReferenceLabel(3),...
    'Callback',{@selectRecord,hReference,hReferenceLabel});
OBRfile();

hDelay=addblock(dlg,'edit_button',{'Delay (ns):' ' Calculate '},20);
set(hDelay(2),'Enable','off');
set(hDelay(3),'Callback',@calculateDelay);
    function calculateDelay(varargin)
        measurement=strtrim(get(hMeasurement(2),'String'));
        if isempty(measurement)
            return
        end
        measurement={measurement get(hMeasurementLabel(2),'String')};
        reference=get(hReference(2),'String');
        if isempty(reference)
            return
        end
        if logical(get(hSelect(1),'Value'))
            reference=strtrim(reference);
            reference={reference get(hReferenceLabel(2),'String')};
        else
            index=get(hReference(2),'Value');                   
            reference=sscanf(reference{index},'%#s %g');
            index=object.OBRreference(:,1)==reference;
            reference=object.OBRreference(index,2);           
        end
        delay=characterizeProbe(object,measurement,reference);
        set(hDelay(2),'String',sprintf('%.3f',delay));        
    end

hButton=addblock(dlg,'button',{' Apply ' ' Done '});
set(hButton(1),'Callback',@apply);
    function apply(varargin)
        delay=get(hDelay(2),'String');
        if isempty(sscanf(delay,'%g'))
            return
        end        
        index=get(hProbe(2),'Value');    
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

function selectFile(~,~,hFile,hLabel)

[filename,pathname]=uigetfile('*.*','Select measurement file');
if isnumeric(filename)
    return
end
filename=fullfile(pathname,filename);
set(hFile(2),'String',filename);

[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.sda'
        selectRecord([],[],hFile,hLabel);
        set(hLabel(3),'Enable','on');
    otherwise
        set(hLabel(2),'String','');
        set(hLabel(2:3),'Enable','off');
end

end

function selectRecord(~,~,hFile,hLabel)

filename=get(hFile(2),'String');
object=SMASH.FileAccess.SDAfile(filename);
choice=select(object);
if ischar(choice)
    set(hLabel(2),'String',choice);
end
 
end