% This class creates a SMASH.ColdOpacity.ColdOpacity object.  This class is
% used to calculate the opacity and transmission of room temperature
% materials (elements 1-92) as well as chemical compounds.  The calculation
% uses data from the Center for X-Ray Optics which can be found at
% (CXRO: http://henke.lbl.gov/optical_constants/filter2.html)
%
% Creating a ColdOpacity object by giving a material and an energy range
% (eV) populates the object with the opacity in cm^2/g.  If no energy range
% is specified the defaul (10->10000 eV) is used. From this
% information the transmission can be calculated (for example for PCD or
% spectrometer filters).  The transmission through a series of different
% filters is found by multiplying the individual transmission curves
% together.
%
% If a ColdOpacity object is created by passing [], then a GUI opens
% allowing the user to select the material and energy range.
%
% A ColdOpacity object is created:
%   >> object=ColdOpacity(material);
%
% See also Xray, Spectrum
%
%
% created May 30, 2014 by Patrick Knapp (Sandia National Laboratories)
%
classdef ColdOpacity < SMASH.Spectroscopy.Spectrum
    %% properties
    properties (SetAccess={?SMASH.DataClass}) % core data
        
    end
    
    properties
        Material = [];
        Thickness = []; %microns
        Density = [];
    end
    %% constructor
    methods (Hidden=true)
        function object=ColdOpacity(varargin)
            object=object@SMASH.Spectroscopy.Spectrum(varargin{:});
            if nargin > 0 && strcmpi(varargin{1},'restore')
                % Do nothing
            elseif length(varargin) == 1
                if ~isempty(varargin{1})
                    
                    object.GridType = 'Energy';
                    object.Material = varargin{1};
                    
                    object.Grid = [];
                    object = CalculateOpacity(object);
                    object.DataLabel = 'Opacity [cm^2/g]';
                    
                elseif isempty(varargin{1})
                    
                    object.GridType = 'Energy';
                    object = ChooseOpacity(object);
                    object = CalculateOpacity(object);
                    object.DataLabel = 'Opacity [cm^2/g]';
                    
                    
                end
            elseif length(varargin) == 2
                object.GridType = 'Energy';
                object.Material = varargin{1};
                E = varargin{2};
                hnu = linspace(E(1),E(2),E(3));
                
                object.Grid = hnu;
                object = CalculateOpacity(object);
                object.DataLabel = 'Opacity [cm^2/g]';
                
            end
            object.Name='Cold Opacity Object';
            object.Title='Cold Opacity Object';
        end
    end
    %%
    methods (Hidden=false)
        varargout=CalculateOpacity(varargin)
        varargout=CalculateTransmission(varargin)
        varargout=ChooseOpacity(varargin)
    end
end