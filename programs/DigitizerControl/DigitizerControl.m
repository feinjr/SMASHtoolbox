function varargout=DigitizerControl(address,fontsize)

% manage input
if (nargin < 1) || isempty(address)
    address='';
end
assert(ischar(address) || iscellstr(address),...
    'ERROR: invalid address list');

if (nargin < 2)  || isempty(fontsize)
    fontsize=12;
end

% 
SMASH.Z.Digitizer.reset();

% select digitizers
fig=makeGUI(fontsize);
if ~isempty(address)
    dig=SMASH.Z.Digitizer.scan(address);    
    updateControls(fig,dig);
end

% manage output
if isdeployed
    varargout{1}=0;
end

end