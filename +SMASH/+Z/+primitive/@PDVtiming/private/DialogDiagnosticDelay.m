function DialogDiagnosticDelay(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Diagnostic delays';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

hTable=addblock(dlg,'table',{'Diagnostic' 'Delay (ns)'},[0 12],10);
N=numel(object.Diagnostic);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.Diagnostic(n));
   data{n,2}=sprintf('%.3f',object.DiagnosticDelay(n));
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

function measureDelay(~,~,object,table)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Measure diagnostic delays';

width=40;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

N=numel(object.Diagnostic);
label=cell(N,1);
for n=1:N
    label{n}=sprintf('%d',object.Diagnostic(n));
end
hDiagnostic=addblock(dlg,'popup','Diagnostic:',label);

hMeasurement=addblock(dlg,'edit_button',...
    {'Measurement file:',' Select '},width);
set(hMeasurement(3),'Callback',@selectFile1);
    function selectFile1(varargin)
        [filename,pathname]=uigetfile('*.*','Select measurement file');
        if isnumeric(filename)
            return
        end
        set(hMeasurement(2),'String',fullfile(pathname,filename));
    end
set(hMeasurement,'TooltipString','Optical fiducial through PDV channel');

hReference=addblock(dlg,'edit_button',...
    {'Reference file:',' Select '},width);
set(hReference(3),'Callback',@selectFile2);
    function selectFile2(varargin)
        [filename,pathname]=uigetfile('*.*','Select measurement file');
        if isnumeric(filename)
            return
        end
        set(hReference(2),'String',fullfile(pathname,filename));
    end
set(hReference,'TooltipString','Optical fiducial through reference detector');

hOffset=addblock(dlg,'edit','Offset (ns):',10);
set(hOffset(2),'String','0','UserData','0',...
    'Callback',@readEditDouble);
set(hOffset,'TooltipString','Detector + cable delay');

hDelay=addblock(dlg,'edit_button',{'Delay (ns):' ' Calculate '},20);
set(hDelay(2),'Enable','off');
set(hDelay(3),'Callback',@calculateDelay);
    function calculateDelay(varargin)
        filename1=get(hMeasurement(2),'String');
        if isempty(filename1)
            return
        end
        filename2=get(hReference(2),'String');
        if isempty(filename2)
            return
        end
        offset=sscanf(get(hOffset(2),'String'),'%g');
        delay=characterizeDiagnostic(object,filename1,filename2,offset);
        set(hDelay(2),'String',sprintf('%.3f',delay));
    end

hButton=addblock(dlg,'button',{' Apply ' ' Done '});
set(hButton(1),'Callback',@apply);
    function apply(varargin)
        delay=get(hDelay(2),'String');
        if isempty(sscanf(delay,'%g'))
            return
        end  
        current=get(hDiagnostic(2),'String');
        index=get(hDiagnostic(2),'Value');  
        current=strtrim(current{index});
        data=get(table,'Data');
        for row=1:size(data,1) 
            temp=strtrim(data{row,1});            
            if strcmp(current,temp);
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

end