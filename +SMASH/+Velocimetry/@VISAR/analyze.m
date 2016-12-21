% ANALYZE -Obtain the velocity from a VISAR object
%
%  This method calculates the velocity record for a VISAR object
%     >> object=analyze(object);
%
% This method uses the current fringe shift to calculate the velocity.  To
% adjust the fringe shift one must run the adjustFringes method.  This is
% particularly true if any fringes were added or subtracted with the
% command window.
%
% Created March 17 by Paul Specht (Sandia National Laboratories)
% Updated December 21 2016 by Paul Specht (Sandia National Laboratories)

function object=analyze(object)

assert(isa(object.FringeShift,'SMASH.SignalAnalysis.Signal'),...
    'ERROR: Must Process Signal to Analyze');

%calculate velocity 
object=process(object);
V=object.InitialVelocity+object.VPF*object.FringeShift;
X=integrate(V);
object.Velocity=V;
object.Displacement=X;