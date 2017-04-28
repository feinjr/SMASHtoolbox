function varargout=DigitizerControl(address)

% manage input
if (nargin < 1) || isempty(address)
    address='*';
end
 
assert(ischar(address) || iscellstr(address),...
    'ERROR: invalid address list');

% select digitizers
makeGUI;
%selectDigitizers(address);

% manage output
if isdeployed
    varargout{1}=0;
end

end