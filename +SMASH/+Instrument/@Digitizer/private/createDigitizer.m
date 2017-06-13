function object=createDigitizer(object,address,name)

% manage input
assert(nargin >= 2 ,'ERROR: no address(es) specified');
if ischar(address)
    address={address};
end
assert(iscellstr(address),'ERROR: invalid address(es)');

%address=SMASH.Instrument.scan(address);
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
for n=1:numel(address)
    for m=(n+1):numel(address)
        assert(~strcmp(address{n},address{m}),...
            'ERROR: each address must be unique');
    end
end

%%
for n=1:numel(address)
    % sort out VISA object
    existing=instrfindall('RemoteHost',address{n});
    if ~isempty(existing)
        delete(existing);
    end
    object(n).VISA=visa(...
        'AGILENT',sprintf('TCPIP::%s',address{n})); %#ok<TNMLP>    
    object(n).VISA.Tag='Digitizer';
    object(n).VISA.Timeout=1; % second
    if strcmpi(object(n).VISA.Status,'closed')
        fopen(object(n).VISA); % Tek test?
    end
    object(n).Name=name{n};
    % set up communications
    fwrite(object(n).VISA,'SYSTEM:LONGFORM ON');
    fwrite(object(n).VISA,'*IDN?');
    temp=strtrim(fscanf(object(n).VISA));
    object(n).System=setupSystem(temp,address{n});
    % digitizer class detection under construction
    object(n).System.Class='Infiniium'; % manual override
    object(n).RemoteDirectory=struct(...
        'Location','C:\Users\Sandia\Data','ShareName','Data');
end

end