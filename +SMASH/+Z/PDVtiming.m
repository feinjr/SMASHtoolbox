% PDVtiming PDV timing analysis
%
%

%
%
%
function varargout=PDVtiming(filename)

% manage input
if nargin<1
    filename='';
end

% create object
object=SMASH.Z.primitive.PDVtiming(filename,'gui');

% manage output
if nargout>0
    varargout{1}=object;
end

end