% SPLIT Divide SignalGroup into Signal objects
%
% This method breaks up a SignalGroup object into a collection of Signal
% objects.
%    >> [object1,object2,...]=split(object)
%
% See also SignalGroup, gather
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
%

function varargout=split(object)

assert(nargout<=object.NumberSignals,...
    'ERROR: too many outputs requested');
varargout=cell(1,object.NumberSignals);

bound=limit(object);
bound=[min(bound) max(bound)];
for n=1:object.NumberSignals
    varargout{n}=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    varargout{n}=limit(varargout{n},bound);
    varargout{n}.Source='SignalGroup split';    
end

end