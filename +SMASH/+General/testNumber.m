% testNumber Apply number tests
%
% This function function applies various number tests to a variable.  A
% basic call:
%    >> result=testNumber(value);
% determines if the variable "value" contains a single, finite number (not NaN or
% an empty value).  Additional tests--positive, negative, integer, and
% finite--can be requested by adding sequential inputs.
%    >> result=testnumber(value,'positive','integer');
%
% See also General
%

%
% created July 16, 2014 by Daniel Dolan (Sandia National Laboratories
% 
function result=testNumber(value,varargin)

result=false;

% basic tests
if isnumeric(value) && isscalar(value) && ~isempty(value) ...
        && ~isnan(value) && ~isinf(value)
    % do nothing
else
    return
end

% advanced tests
for n=1:numel(varargin)
    switch varargin{n}
        case 'positive'
            if ~(value>=0)
                return
            end
        case 'negative'
            if ~(value<0)
                return
            end
        case 'integer'
            if ~(value==floor(value))
                return
            end 
        otherwise
            error('ERROR: invalid test requested');
    end
end

% all tests passed
result=true;