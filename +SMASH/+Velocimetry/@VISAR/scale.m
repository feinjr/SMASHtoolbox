% SCALE - Scale a VISAR object Grid 
%
% This method multiplies a VISAR object's Grid by a scalar value.
% This scaling is applied to all grids in the VISAR object and all
% time-based quantities.  The possible syntaxes are below.
%      >> object=scale(object,value);
%
% created March 15 2016 by Paul Specht (Sandia National Laboratories) 
%
function object=scale(object,value)

% handle input
if nargin<2
    error('ERROR: Shift Value Must be Specified');
end

if isempty(value) || (numel(value)~=1)
    error('ERROR: Shift Value Must be a Scalar');
end

value=abs(value);

% apply scaling to measurement
object.Measurement=scale(object.Measurement,value);

%apply scaling to time shifts if exist
if isempty(object.TimeShifts) ~= 1
    object.TimeShifts=object.TimeShifts*value;
end

%apply to Reference Region if exists
if isempty(object.ReferenceRegion) ~= 1
    object.ReferenceRegion=object.ReferenceRegion*value;
end

%apply to Experimental Region if exists
if isempty(object.ExperimentalRegion) ~= 1
    object.ExperimentalRegion=object.ExperimentalRegion*value;
end

%apply to Fringe Jumps are defined
if isempty(object.Jumps) ~= 1
    J=object.Jumps;
    for k=1:size(J,1)
        J(k,2)=J(k,2)*value;
        J(k,3)=J(k,3)*value;
    end
    object.Jumps=J;
end

%apply to Processed signal if exists
if isa(object.Processed,'SMASH.SignalAnalysis.SignalGroup')
    object.Processed=scale(object.Processed,value);
end

%apply to quadrature signals if exists
if isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup')
    object.Quadrature=scale(object.Quadrature,value);
end

%apply to fringe shift signal if exists
if isa(object.FringeShift,'SMASH.SignalAnalysis.Signal')
    object.FringeShift=scale(object.FringeShift,value);
end

%apply to Contrast signal if exists
if isa(object.Contrast,'SMASH.SignalAnalysis.Signal')
    object.Contrast=scale(object.Contrast,value);
end

%apply to velocity signal if exists
if isa(object.Velocity,'SMASH.SignalAnalysis.Signal')
    object.Velocity=scale(object.Contrast,value);
end

end