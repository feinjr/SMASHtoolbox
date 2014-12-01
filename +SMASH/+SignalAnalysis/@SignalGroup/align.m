% * method disabled *
%
% See also SignalGroup

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function align(varargin)

message={};
message{end+1}='ERROR: method not supported for SignalGroup objects';
message{end+1}='Use "gather" method to align Signal grids, then "split" as necessary';
error('%s\n',message{:});

end