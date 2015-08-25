% This method generates a Vinet Model object
%
%     >> object=Vinet(object);
%
% Model properties include:
%       
%       rho0  : Initial density
%       T0    : Reference temperature
%       alpha : Constant volumetric thermal expansion
%       cv    : Constant-volume specific heat
%       B0    : Reference bulk modulus
%       BP0   : First pressure derivative of the bulk modulus
%       d     : Vector array of [d2,d3,...] cold curve expansion coefficients
%
% The formulation follows the extended Alegra (see manual) implementation. 
% The pressure as a function of density and temperature is given as
%
%       P(rho,T) = Pref(rho)+alpha*B0(T-T0)
% 
% The reference pressure curve is given as:
%
%       Pref(X) = (3*B0/X^2)(1-X)exp(eta0(1-X))*sum(exp(di*(1-X)^i)
%
%                   eta0 = 3/2(BP0-1)
%
% where X = (rho0/rho)^(1/3), and di is the ith d coefficient.
%
% See also EOS, calibrate, evaluate

%
% created January 9, 2015 by Justin Brown (Sandia National Laboratories)
%

classdef Vinet
    %%
    properties 
        rho0 = 0 % Reference density
        T0 = 298 % Reference temperature
        alpha = 0 % Thermal expansion
        cv = 0 % Heat capacity
        B0 = 0 % Bulk modulus
        BP0 = 0 % Pressure derivative of bulk modulus
        d = [0] % Higher order coefficients (arbitrary number)
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
        function object=set.alpha(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid alpha');
            assert(value>0,'ERROR: alpha must be > 0');
            object.alpha=value;
        end
        function object=set.cv(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid cv');
            assert(value>0,'ERROR: cv must be > 0');
            object.cv=value;
        end
        function object=set.B0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid B0');
            assert(value>0,'ERROR: B0 must be > 0');
            object.B0=value;
        end
        function object=set.BP0(object,value)
            assert((isnumeric(value) & isscalar(value) & isfinite(value)),'ERROR: invalid BP0');
%            assert(value>0,'ERROR: BP0 must be > 0');
            object.BP0=value;
        end
        function object=set.d(object,value)
            %assert((isnumeric(value) & isfinite(value)),'ERROR: invalid d');
            object.d=value;
        end
    end
end