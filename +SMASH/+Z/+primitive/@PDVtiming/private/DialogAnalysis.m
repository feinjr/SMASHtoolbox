function DialogAnalysis(~,~,object)

[result,connect,label]=analyze(object);
N=numel(result);
if N==0
    h=errordlg('No connections have been defined','No connections','modal');
    uiwait(h);
    return
end

data=cell(N,6);
for n=1:N
    for k=1:4;
        data{n,k}=sprintf('%d',connect(n,1));        
    end
    data{n,5}=sprintf('%.3f',result(n));
    data{n,6}=label{n};
end

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='PDV timing results';

width=40;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);
addblock(dlg,'text','Generated:',width);
addblock(dlg,'text',['   ' datestr(now)],width);

h=addblock(dlg,'table',...
    {'Probe' 'Diagnostic' 'Digitizer' 'Channel' 'Correction' 'Measurement'},...
    [5 5 5 5 10 20],10);
ColumnEditable=false(1,6);
ColumnFormat=cell(1,6);
for m=1:6
    ColumnEditable(m)=false;
    ColumnFormat{m}='char';
end
set(h(end),'Data',data,...
    'ColumnEditable',ColumnEditable,'ColumnFormat',ColumnFormat);

h=addblock(dlg,'button',' Close ');
set(h,'Callback',@closeDialog);
    function closeDialog(varargin)
        delete(dlg);
    end

locate(dlg,'center');
dlg.Hidden=false;

end