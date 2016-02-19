function DialogOBRreferences(~,~,object)

dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='OBR reference times';

width=30;
addblock(dlg,'text','Experiment:',width);
addblock(dlg,'text',['   ' object.Experiment],width);

Nchannel=size(object.OBRreference,1);
hChannels=addblock(dlg,'edit_button',{'Num. channels:',' Apply '});
value=sprintf('%d',Nchannel);
set(hChannels(2),'Callback',@readEditInteger,'String',value,'UserData',value);
set(hChannels(3),'Callback',@applyNchannel);
    function applyNchannel(varargin)
        Nchannel=sscanf(get(hChannels(2),'String'),'%d');
        data=get(hTable(end),'Data');
        if InitializeData
            N=size(object.OBRreference,1);
            data=cell(N,2);
            for n=1:N
                data{n,1}=sprintf('%d',object.OBRreference(n,1));
                data{n,2}=sprintf('%.3f',object.OBRreference(n,2));
            end
            set(hTable(end),'CellEditCallback',@readTableDouble,...
                'ColumnEditable',[false true],...
                'ColumnFormat',{'char' 'char'},...
                'Data',data);
        end
        Mdata=size(data,1);
        if Mdata < Nchannel
            data{Nchannel,2}='';
            for mm=(Mdata+1):Nchannel
                data{mm,1}=sprintf('%d',mm);
                data{mm,2}=sprintf('%d',0);
            end
        elseif Mdata > Nchannel
            LastEntry=nan;
            for mm=1:Mdata
                temp=data(mm,:);
                temp=strtrim(sprintf('%s ',temp{:}));
                if ~isempty(temp)
                    LastEntry=mm;
                end
            end
            if LastEntry > Nchannel
                choice=questdlg('This setting will drop existing channels',...
                    'Drop channels?',' Proceed ',' Cancel ',' Cancel ');
                choice=strtrim(choice);
                if strcmpi(choice,'proceed')
                    % continue
                else
                    value=size(get(hTable(end),'Data'),1);
                    set(hChannels(2),'String',value,'UserData',value);
                    return
                end           
            end
            data=data(1:Nchannel,:);
        end                  
        set(hTable(end),'Data',data);                        
    end

hTable=addblock(dlg,'table',{'OBR channel' 'Ref. transit (ns)'},[0 12],10);
InitializeData=true;
applyNchannel()

h=addblock(dlg,'button',{' Done ' ' Cancel '});
set(h(1),'Callback',@done)
    function done(varargin)
        value=probe(dlg);        
        table=nan(Nchannel,2);        
        for k=1:Nchannel;
            table(k,1)=k;
            table(k,2)=sscanf(value{2}{k,2},'%g');
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