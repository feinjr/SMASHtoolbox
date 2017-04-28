function selectDigitizers(address)

dig=verifyAddress(address);

box=SMASH.MUI.Dialog;
box.Name='Select digitizers';

scan=addblock(box,'button','Scan range');

h=addblock(box,'table',{'Address' 'Model' 'Serial number' 'Name'},...
    [15 15 15 15],10);
data=get(h(end),'Data');
for k=1:max(size(data,1),numel(dig))
    if k <= numel(dig)
        data{k,1}=dig{k};
    else
        data{k,1}='';
    end
end
set(h(end),'Data',data);

buttons=addblock(box,'button',{'Update' 'Done'});



end

function dig=verifyAddress(address)

if ischar(address)
    address=SMASH.System.listIP4(address);
end

delay=SMASH.System.ping(address,200); % 200 ms time out
valid=address(~isnan(delay));

%dig=SMASH.Z.Digitizer.scan(valid);
dig=valid;


end