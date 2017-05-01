function varargout=DigitizerControl(address,fontsize)

% manage input
if (nargin < 1) || isempty(address)
    address='*';
end

if (nargin < 2)  || isempty(fontsize)
    fontsize=12;
end
 
assert(ischar(address) || iscellstr(address),...
    'ERROR: invalid address list');

% select digitizers
makeGUI(fontsize);
%selectDigitizers(address);

% manage output
if isdeployed
    varargout{1}=0;
end

end