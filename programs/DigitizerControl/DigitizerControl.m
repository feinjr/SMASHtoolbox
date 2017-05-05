function varargout=DigitizerControl(address,fontsize)

h=findall(0,'Tag','DigitizerControl');
if ishandle(h)
    fprintf('Program already running...making active\n');
    figure(h);    
    return
end

% manage input
if (nargin < 1) || isempty(address)
    address='';
end
assert(ischar(address) || iscellstr(address),...
    'ERROR: invalid address list');

if (nargin < 2)  || isempty(fontsize)
    fontsize=14;
end

% 
SMASH.Z.Digitizer.reset();

% select digitizers
fig=makeGUI(fontsize);
if ~isempty(address)
    dig=SMASH.Z.Digitizer.scan(address); 
    for n=1:numel(dig)
        dig(n).Name=sprintf('Digitizer%d',n);
    end
    updateControls(fig,dig);
end

% manage output
if isdeployed
    varargout{1}=0;
end

end