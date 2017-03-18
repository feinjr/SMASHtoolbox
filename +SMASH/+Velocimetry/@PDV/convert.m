% convert Custom velocity conversion
%
% This method allows custom conversions of frequency to velocity.
%    result=convert(object,myfunc);
% The input "myfunc" must be a handle to a function that accepts three
% inputs and returns one output.  For example:
%    function velocity=myfunc(index,time,frequency)
%      (custom code)
% would translate the frequency to velocity based on the bounded region
% index.  The output "result" is the resulting velocities stored as a cell
% array of Signal objects.
%
% NOTE: custom conversion is meant for advanced users.  Velocity is
% automatically calculated once the PDV wavelength and reference frequency
% are specified, and this conversion is adequeate in many situations.
%
% See also PDV, analyze
%

%
% created March 18, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function result=convert(object,target)

% manage input
assert(object.Analyzed,'ERROR: analysis has not been performed yet');
assert(nargin >= 2,'ERROR: no conversion function specified');
if ischar(target)
    target=str2func(target);
end
assert(isa(target,'function_handle'),'ERROR: invalid conversion function');

% perform conversion
result=object.Frequency;
for n=1:numel(result)
    temp=target(n,result{n}.Grid,result{n}.Data);
    result{n}=reset(result{n},[],temp);
end

end
