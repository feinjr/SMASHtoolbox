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
% created March 3, 2017 by Patrick Knapp (Sandia National Laboratories)
%
classdef ColdOpacity
    %% properties
    properties (SetAccess={?SMASH.DataClass}) % core data
        Opacity
        Transmission
    end
    
    properties
        Settings
    end
    %% constructor
    methods (Hidden=true)
        function object=ColdOpacity(varargin)
            p = struct();
            if isempty(varargin)
                object = ChooseOpacity(object);
                object = CalculateOpacity(object);
                object = CalculateTransmission(object);
                             
            elseif (nargin == 1) && ( ischar(varargin{1}) || iscell(varargin{1}))
                p.Material =  varargin{1};      % string containing the material
                p.Energy = [10, 30000, 1000];   % min, max, and Npts [eV]
                p.Thickness = [];               % thickness in microns
                p.Density = '';                 % density in g/cm^3
                object.Settings = p;

                object = CalculateOpacity(object);
                object = CalculateTransmission(object);
                
            elseif (nargin == 1) && isobject(varargin{1});
                p.Energy = [min(varargin{1}.Grid), max(varargin{1}.Grid), numel(varargin{1}.Grid)];
                p.Density = '';
                p.Thickness = [];
                object.Settings = p;
                
                varargin{1}=SMASH.SignalAnalysis.Signal(varargin{1}.Grid,varargin{1}.Data);
                object.Opacity=varargin{1};
                
            elseif nargin > 1
                material = '';
                thickness = [];
                density = [];
                energy = [10, 30000, 1000];
                
                for i = 1:nargin
                    if strcmp(varargin{i},'Material');  material = varargin{i+1};   end
                    if strcmp(varargin{i},'Energy');    energy = varargin{i+1};     end
                    if strcmp(varargin{i},'Thickness'); thickness = varargin{i+1};  end
                    if strcmp(varargin{i},'Density');   density = varargin{i+1};    end
                end
                
                p.Material = material;
                p.Thickness = thickness;
                p.Energy = energy;
                p.Density = density;
                object.Settings = p;
                
                object = CalculateOpacity(object);
                object = CalculateTransmission(object);             
            end
        end
    end
    %%
    methods (Hidden=false)
        varargout=CalculateOpacity(varargin)
        varargout=CalculateTransmission(varargin)
        varargout=ChooseOpacity(varargin)
    end
end