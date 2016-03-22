% bound Define frequency bounds
%
% This method defines the frequency bounds used during sinusoidal
% optimization.  Simple frequency bounds may be specified by a pair of
% numbers.
%    object=bound(object,[fmin fmax]);
% Minimum/maximum allowed frequencies are defined over object's current
% Time property.  If the time range is changed, this method should be
% recalled to properly update the frequency bounds.
%    object=reset(object,time,signal); % revise signal
%    object=bound(object); % update bound for revised signal
%
% Time-dependent frequency bounds may be specified by passing a
% BoundingCurve object.
%    object=bound(object,bnd); % pass BoundingCurve object
% Passing a cell array of BoundingCurve objects specifies multiple
% frequency bounds.
%    object=bound(object,{bnd1 bnd2}); % pass two BoundingCurve objects
%
% See also SinusoidFit, reset, SMASH.ROI.BoundingCurve
%

%
% created March 22, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=bound(object,value)

% manage input
if nargin<2
    value=object.FrequencyBound;
    try
        value=value{1};
        assert(isa(value,'SMASH.ROI.BoundaryCurve'));
    catch
        error('ERROR: cannot update frequency bound');
    end
    data=value.Data;
    time=object.Time;
    time=[min(time) max(time)];
    for col=2:3
        data(:,col)=interp1(data(:,1),data(:,col),time,'nearest');
    end
    value=define(value,data);
end

% deal with different boundary types
if isnumeric(value)
    assert(numel(value)==2,'ERROR: invalid frequency bound');
    value=sort(value);
    data=nan(2,3);
    data(1,1)=min(object.Time);
    data(2,1)=max(object.Time);
    data(:,2)=mean(value);
    data(:,3)=(value(2)-value(1))/2;
    value=SMASH.ROI.BoundingCurve('horizontal');
    value=define(value,data);
end

if isa(value,'SMASH.ROI.BoundaryCurve')
    value={value};
end

assert(iscell(value),'ERROR: invalid bound input');
for n=1:numel(value)
    assert(isa(value{n},'SMASH.ROI.BoundaryCurve'),...
        'ERROR: invalid bound input');
end

object.FrequencyBound=value;

end