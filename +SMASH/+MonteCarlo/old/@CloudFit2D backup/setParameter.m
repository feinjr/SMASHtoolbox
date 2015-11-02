% UNDER CONSTRUCTION
function object=setParameter(object,varargin)

assert(isa(object.Model,'SMASH.MonteCarlo.Support.Model2D'),...
    'ERROR: cannot set parameters becuase no model is defined');
object.Model=setParameter(object.Model,varargin{:});

end