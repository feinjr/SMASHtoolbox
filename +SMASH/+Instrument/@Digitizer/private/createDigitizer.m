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

%%
%object=repmat(object,size(address));
for n=1:numel(address)
    % sort out VISA object
    existing=instrfindall('Tag','Digitizer');
    new=true;
    for m=1:numel(existing)
        if strcmp(existing(m).RemoteHost,address{n})
            object(n).VISA=existing(m);
            new=false;
            break
        end
    end
    if new
        object(n).VISA=visa(...
            'AGILENT',sprintf('TCPIP::%s',address{n})); %#ok<TNMLP>
    end
    object(n).VISA.Tag='Digitizer';
    object(n).VISA.Timeout=1; % second
    try
        if strcmpi(object(n).VISA.Status,'closed')
            fopen(object(n).VISA);
        end
    catch
        error('ERROR: only Agilent/Keysight digitizers supported at this time');
    end
    object(n).Name=name{1};
    % set up communications
    fwrite(object(n).VISA,'SYSTEM:LONGFORM ON');
    fwrite(object(n).VISA,'*IDN?');
    temp=strtrim(fscanf(object(n).VISA));
    object(n).System=setupSystem(temp,address{n});
    % class detection under construction
    object(n).System.Class='Infiniium'; % manual override
    object(n).RemoteDirectory=struct(...
        'Location','C:\Users\Sandia\Data','ShareName','Data');
end

end