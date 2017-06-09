function object=createDigitizer(object,address,name)

% manage input
assert(nargin >= 2 ,'ERROR: no address(es) specified');
if ischar(address)
    address={address};
end
assert(iscellstr(address),'ERROR: invalid address(es)');

address=SMASH.Instrument.scan(address);
assert(~isempty(address),'ERROR: no valid address found');
if (nargin < 3) || isempty(name)
    name=cell(size(address));
    for n=1:numel(address)
        name{n}=sprintf('Digitizer%d',n);
    end
elseif ischar(name)
    name={name};
else
    assert(iscellstr(name),'ERROR: invalid name input');
end
assert(numel(name) == numel(address),...
    'ERROR: incompatible address/name inputs');

% deal with multiple addresses
if numel(address) > 1
    for n=1:numel(address)
        object(n)=SMASH.Instrument.Digitizer(object,address{n},name{n}); 
        if n == 1
            object=repmat(object,size(address));
        end
    end
    return
end

% deal with a single address
existing=instrfindall('Tag','Digitizer');
for n=1:numel(existing)
    if strcmp(existing(n).RemoteHost,address{1})
        object.VISA=existing(n);
        break
    end
end

if isempty(object.VISA)
    try
        object.VISA=visa('AGILENT',sprintf('TCPIP::%s',address{1}));
        object.VISA.Timeout=1;
        fopen(object.VISA);
    catch
        error('ERROR: only Agilent/Keysight digitizers supported at this time');
    end
end
fwrite(object.VISA,'SYSTEM:LONGFORM ON');
fwrite(object.VISA,'*IDN?');
temp=strtrim(fscanf(object.VISA));
object.System=setupSystem(temp,address{1});

%object=identifySystem(object);
object.System.Class='Infiniium'; % manual override

object.Name=name{1};
object.VISA.Tag='Digitizer';

object.RemoteDirectory=struct(...
    'Location','C:\Users\Sandia\Data','ShareName','Data');

end