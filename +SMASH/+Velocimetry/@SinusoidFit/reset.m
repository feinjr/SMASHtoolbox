% reset Reset object properties
%
% This method resets object properties, allowing existing objects to be
% reused.
%    object=reset(object,time);
%    object=reset(object,time,signal);
%    object=reset(object,time,signal,tolerance);
% Passing an empty argument leaves the corresponding property unchanged.
%
% This method performs a number of error checks and sorts the
% time/signal input.  Passing a fifth input bypasses these operations.
%    object=reset(object,time,signal,tolerance,'bypass');  
% This feature should only be used when an object is repeatedly reset when
% one is *certain* that the time/signal/tolerance input are valid.
%
% See also Sinusoid
%

%
% created March 21, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,time,signal,tolerance,bypass)

% manage input
if (nargin<2) || isempty(time)
    assert(~isempty(object.Time),'ERROR: no time base defined');
    time=object.Time;
end

if (nargin<3) || isempty(signal)   
    assert(~isempty(object.Signal),'ERROR: no signal defined');
    signal=object.Signal;
end

if (nargin<4) || isempty(tolerance)
    assert(~isempty(object.BreakTolerance),'ERROR: no tolerance defined');
    tolerance=object.BreakTolerance;
end

if (nargin<5) || isempty(bypass)
    bypass=false;
elseif strcmpi(bypass,'bypass');
    bypass=true;
end

% reset object properties
time=time(:);
signal=signal(:);
if ~bypass
    assert(isnumeric(time),'ERROR: invalid time array');
    assert(numel(signal)==numel(time),...
        'ERROR: inconsistent time/signal input');
    assert(isnumeric(tolerance) && isscalar(tolerance) && (tolerance>0),...
        'ERROR: invalid tolerance value');
    [time,index]=sort(time);
    signal=signal(index);
end

object.Time=time;
object.Signal=signal;

object.BreakTolerance=tolerance;

object.Curve=[];

end