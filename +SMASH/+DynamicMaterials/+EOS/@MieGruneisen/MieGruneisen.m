% This method generates a Mie-Gruneisen Model object
%
%     >> object=MieGruneisen(object)
%
% Model properties include:
%       
%       rho0  : Initial density
%       c0    : Initial sound speed
%       s     : Hugoniot slope 
%       gamma : Initial Gruneisen coefficient
%       T0    : Reference temperature
%       cv    : Constant-volume specific heat
%
% The reference Hugoniot specifed by rho0, c0, and s is used in the
% Mie-Gruneisen formulation to generate the EOS. Gamma is assumed to have
% the form gamma*rho = gamma0*rho0
%
% See also EOS, calibrate, calibrateUsup, evaluate, evaluateHugoniot

%
% created January 9, 2015 by Justin Brown (Sandia National Laboratories)
%

classdef MieGruneisen
    %%
    properties 
        rho0 = 0 % Reference density
        c0 = 0   % Hugoniot sound speed
        s = 0    % Hugoniot slope
        gamma = 0 % Initial Gruneisen coeff
        T0 = 298 % Reference temperature
        cv = 0 % Heat capacity

    end

    %%
    methods (Hidden=true)
        function object=MieGruneisen(varargin)
        end
    end
    
    %%
    methods (Access=protected,Hidden=true)
        varargout=calculateMG(varargin)
    end
   
    %% setters
    methods
        function object=set.rho0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid rho0');
            assert(value>0,'ERROR: rho0 must be > 0');
            object.rho0=value;
        end
        function object=set.c0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid c0');
            assert(value>0,'ERROR: c0 must be > 0');
            object.c0=value;
        end
        function object=set.s(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid s');
            assert(value>0,'ERROR: s must be > 0');
            object.s=value;
        end
        function object=set.gamma(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid gamma');
            assert(value>0,'ERROR: gamma must be > 0');
            object.gamma=value;
        end
        function object=set.cv(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid cv');
            assert(value>0,'ERROR: cv must be > 0');
            object.cv=value;
        end
        function object=set.T0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid T0');
            assert(value>0,'ERROR: T0 must be > 0');
            object.T0=value;
        end
    end
end