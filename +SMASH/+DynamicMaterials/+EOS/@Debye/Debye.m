% This method generates a Debye Model object
%
%     >> object=Debye(object);
%
% Model properties include:
%       
%       rho0  : Reference density
%       T0    : Reference debye temperature
%       A     : Molecular weight
%       gtype : Integer referencing the form of gamma
%       p     : Array of parameters associated with gtype
% 
% The model describing the Gruneisen parameter as a function of density is
% described by gytpe, an integer value between 1 and 5. The forms are given
% by:
%
%       gtype = 1 : Constant : gamma = gamma0
%                   p = [gamma0]
%
%
%       gtype = 2 : Power law : gamma = (GR-GI)*pow(eta,-GT)+GI
%                   p = [GI, GR, GT]
%
%
%       gtype = 3 : Polynomial expansion : gamma = GI + A/eta + B/(eta^2)
%                   p = [GI, A, B]
%
%
%       gtype = 4 : Aneos : gamma = GR/eta + GI(1-1/eta)^2
%                   p = [GI, GR]
%
%       
%       gtype = 5 : Sesame : gamma = GR/eta + GI(1-1/eta)
%                   p = [GI, GR]
% where eta = rho/rho0. 
%
% See also EOS, calibrateGamma, evaluateGamma, evaluate
%

%
% created January 15, 2015 by Justin Brown (Sandia National Laboratories)
%

classdef Debye
    %%
    properties 
        rho0 = 0    % Reference density
        T0 = 298    % Reference Debye temperature
        A = 0       % Molecular weight
        gtype = 1   % Function handle defining gamma(rho)
        p = []      % Parameters defining gamma
    end

    %%
    methods (Hidden=true)
        function object=Vinet(varargin)
        end
    end
    
    %%
    methods (Access=protected,Hidden=true)
        varargout=calculateVinet(varargin)
    end
   
    %% setters
    methods
        function object=set.rho0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid rho0');
            assert(value>0,'ERROR: rho0 must be > 0');
            object.rho0=value;
        end
        function object=set.T0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid T0');
            assert(value>0,'ERROR: T0 must be > 0');
            object.T0=value;
        end
        function object=set.A(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid A');
            assert(value>0,'ERROR: A must be > 0');
            object.A=value;
        end
        function object=set.gtype(object,value)
            assert((isscalar(value) & isfinite(value)),'ERROR: invalid gtype');
            value = int32(value);
            assert(value >=1 & value <=5,'ERROR: gtype must be an integer between 1 and 5');
            object.gtype=value;
        end
        function object=set.p(object,value)
            assert(all((isnumeric(value)) & all(isfinite(value))),'ERROR: invalid p');
            object.p=value;
        end

    end
end