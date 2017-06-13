
function dig=selectDigitizers(fig,dig,fontsize)

% manage input
address={};
name={};
for n=1:numel(dig)
    address{end+1}=dig(n).System.Address; %#ok<AGROW>
    name{end+1}=dig(n).Name; %#ok<AGROW>
end

% create dialog box
box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Name='Select digitizers';
box.Hidden=true;
set(box.Handle,'Tag','DigitizerControl:selectDigitizers');

Scan=addblock(box,'edit_button',{'Address range:' ' Scan '});
set(Scan(end),'Callback',@scanRange);
    
table=addblock(box,'table',{'Address' 'Model' 'Serial number' 'Name'},...
    [15 15 15 15],10);
maxrows=100;
data=repmat({''},[maxrows 4]);
for n=1:numel(address)
    data{n,1}=address{n};
    data{n,4}=name{n};
end
set(table(end),'Data',data,'ColumnEditable',[true false false true]);

buttons=addblock(box,'button',{'Update' 'Done'});
set(buttons(1),'Callback',@updateDialog);
set(buttons(2),'Callback',@done);
   
updateDialog();
movegui(box.Handle,'center');
box.Hidden=false;
box.Modal=true;
waitfor(box.Handle);

%% callback functions
    function scanRange(varargin)
        WorkingButton(Scan(end));
        C=onCleanup(@() WorkingButton(Scan(end)));
        address=SMASH.Instrument.scan(get(Scan(2),'String'));
        figure(box.Handle);
        data=cell(size(get(table(end),'Data')));
        for row=1:maxrows
            if row <= numel(address)
                data{row,1}=address{row};
            else
                data{row,1}='';
            end
            data{row,2}='';
            data{row,3}='';
            data{row,4}='';
        end
        set(table(end),'Data',data);
    end
    function updateDialog(varargin)
        WorkingButton(buttons(1));
        data=get(table(end),'Data');
        count=0;
        for row=1:maxrows
            try
                IP=data{row,1};
                assert(~isempty(IP));
                delay=SMASH.System.ping(IP);
                assert(~isnan(delay),'');
                dig=SMASH.Instrument.Digitizer(IP);
                data{row,2}=dig.System.ModelNumber;
                data{row,3}=dig.System.SerialNumber;
                count=count+1;
                if isempty(data{row,4})
                    data{row,4}=sprintf('Digitizer%d',count);
                else
                    data{row,4}=matlab.lang.makeValidName(data{row,4});
                end
                temp=data(1:row,4);
                temp=matlab.lang.makeUniqueStrings(temp);
                data{row,4}=temp{end};
            catch
                data{row,1}='';
                data{row,2}='';
                data{row,3}='';
                data{row,4}='';
            end                        
        end
        set(table(end),'Data',data);
        WorkingButton(buttons(1));
    end
    function done(varargin)
        updateDialog();
        data=get(table(end),'Data');
        address=data(:,1);       
        name=data(:,4);
        keep=true(size(address));
        for row=1:numel(address)
            if isempty(address{row})
                keep(row)=false;
            end
        end
        address=address(keep);
        name=name(keep);
        dig=SMASH.Instrument.Digitizer(address,name);        
        updateControls(fig,dig);
        unlock(dig);
        hlock=findobj(fig.Figure,'Tag','LockMenu');
        hlock=get(hlock,'Children');
        set(hlock,'Checked','off');
        delete(box);
        hl=findobj(fig.Figure','Type','line');
        set(hl,'Visible','off','XData',[],'YData',[]);
        figure(fig.Figure);
    end

end