% This class creates Planck objects for analyzing the thermal radiation
% emitted from a black (or gray) body.
%
% A black body in thermal equilibrium emits electromagnetic radiation
% according to Planck's law, meaning that it has a spectrum that is 
% determined by the temperature alone not by the body's shape or 
% composition. It is an ideal emitter: it emits as much or more energy at 
% every frequency than any other body at the same temperature.  It is also 
% a diffuse emitter: the energy is radiated isotropically, independent of 
% direction.
%
% Real materials emit energy at a fraction of black body energy levels. 
% By definition, a black body in thermal equilibrium has an emissivity of 
% ? = 1.0.  A source with lower emissivity independent of frequency often 
% is referred to as a gray body.
%
% A Planck object is created:
%   >> object=Planck(wavelength,radiance);
% with inputs of wavelength (array) and spectral radiance (array).
%
% To calculate the spectral radiance from Planck's Law, then inputs of 
% temperature (scalar) and emissivity (scalar) are needed:
%   >> object=Planck(wavelength,temperature,emissivity);
%
% See also Spectroscopy, Spectrum
%

% created April 1, 2014 by Tommy Ao (Sandia National Laboratories)
% modified July 8, 2014 by Tommy Ao
%
classdef Planck < SMASH.Spectroscopy.Spectrum
    %% properties
    properties (SetAccess={?SMASH.General.DataClass}) % core data
        Temperature = [] % Temperature (K)
        Emissivity = [] % Emissivity
    end
    %% constructor
    methods (Hidden=true)
        function object=Planck(varargin)
            object=object@SMASH.Spectroscopy.Spectrum(varargin{:});                  
        end
    end
    %% protected methods
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
end
