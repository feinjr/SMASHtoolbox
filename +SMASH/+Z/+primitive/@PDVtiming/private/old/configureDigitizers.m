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