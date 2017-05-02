
function selectDigitizers(fig,arg,fontsize)

% manage input
if isempty(arg)
    address={};
    dig=[];
elseif ischar(arg) || iscellstr(arg)
    [address,dig]=verifyAddress(arg);
elseif isa(arg,'SMASH.Z.Digitizer')
    dig=arg;
    address=cell(size(dig));
    for n=1:numel(dig)
        address{n}=dig(n).System.Address;
    end
else
    error('ERROR: invalid input')
end
       
% create dialog box
box=SMASH.MUI.Dialog('FontSize',fontsize);
box.Name='Select digitizers';
box.Hidden=true;

scan=addblock(box,'edit_button',{'Address range:' ' Scan '});
set(scan(end),'Callback',@scanRange);
    
table=addblock(box,'table',{'Address' 'Model' 'Serial number' 'Name'},...
    [15 15 15 15],10);
maxrows=100;
data=repmat({''},[maxrows 4]);
for n=1:numel(address)
    data{n,1}=address{n};
end
set(table(end),'Data',data);
updateDialog();

buttons=addblock(box,'button',{'Update' 'Done'});
set(buttons(1),'Callback',@updateDialog);
set(buttons(2),'Callback',@done);
   
movegui(box.Handle,'center');
box.Hidden=false;
box.Modal=true;
waitfor(box.Handle);

%% callback functions
    function scanRange(varargin)
        commandwindow;
        [address,~]=verifyAddress(get(scan(2),'String'));
        figure(box.Handle);
        for row=1:maxrows
            if row <= numel(address)
                data{row,1}=address{row};
            else
                data{row,1}='';
            end
        end
        set(table(end),'Data',data);
        updateDialog();
    end
    function updateDialog(varargin)
        data=get(table(end),'Data');
        for row=1:maxrows
            if isempty(data{row,1})
                data{row,2}='';
                data{row,3}='';
                data{row,4}='';
            else
                dig=SMASH.Z.Digitizer(data{row,1});
                data{row,2}=dig.System.ModelNumber;
                data{row,3}=dig.System.SerialNumber;
                if isempty(data{row,4})
                    data{row,4}=dig.Name;
                else
                    dig(row).Name=data{row,4};
                end
            end
        end
        set(table(end),'Data',data);
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
        dig=SMASH.Z.Digitizer.scan(address);
        for row=1:numel(dig)
            dig(row).Name=name{row};
        end
        updateControls(fig,dig);
        delete(box);
    end

end

%%
function [address,dig]=verifyAddress(address)

if ischar(address)
    address=SMASH.System.listIP4(address);
end

delay=SMASH.System.ping(address,200); % 200 ms time out
address=address(~isnan(delay));

dig=SMASH.Z.Digitizer.scan(address);
address=cell(size(dig));
for n=1:numel(address)
    address{n}=dig.System.Address;
end

end