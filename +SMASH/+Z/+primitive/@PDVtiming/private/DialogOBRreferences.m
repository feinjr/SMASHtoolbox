function DialogOBRreferences(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='OBR reference times';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

h=addblock(dlg,'table',{'OBR channel' 'Ref. transit (ns)'},[0 12],10);
N=size(object.OBRreference,1);
data=cell(N,2);
for n=1:N
   data{n,1}=sprintf('%d',object.OBRreference(n,1));
   data{n,2}=sprintf('%.3f',object.OBRreference(n,2));
end
set(h(end),'CellEditCallback',@readTableDouble,...
    'ColumnEditable',[false true],...
    'ColumnFormat',{'char' 'char'},...
    'Data',data);    

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);
        table=nan(size(object.OBRreference));        
        for k=1:size(table,1);
            table(k,1)=k;
            table(k,2)=sscanf(value{1}{k,2},'%g');
        end
        object.OBRreference=table;
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