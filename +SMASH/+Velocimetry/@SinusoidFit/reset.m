% reset Reset object properties
%
% This method resets object properties, allowing existing objects to be
% reused.
%    object=reset(object,time);
%    object=reset(object,time,signal);
%    object=reset(object,time,signal,tolerance);
% Passing an empty argument leaves the corresponding property unchanged.
%
% See also Sinusoid
%

%
% created March 21, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,time,signal,tolerance)

% manage input
if (nargin<2) || isempty(time)
    assert(~isempty(object.Time),'ERROR: no time base defined');
    time=object.Time;
end
assert(isnumeric(time),'ERROR: invalid time array');

if (nargin<3) || isempty(signal)   
    assert(~isempty(object.Signal),'ERROR: no signal defined');
    signal=object.Signal;
end
assert(numel(signal)==numel(time),'ERROR: inconsistent time/signal input');

if (nargin<4) || isempty(tolerance)
    assert(~isempty(object.BreakTolerance),'ERROR: no tolerance defined');
    tolerance=object.BreakTolerance;
end
assert(isnumeric(tolerance) && isscalar(tolerance) && (tolerance>0),...
    'ERROR: invalid tolerance value');

% setup subdomains

% reset object properties
object.Time=time;
object.Signal=signal;
object.BreakTolerance=tolerance;

object.Fit=[];

end