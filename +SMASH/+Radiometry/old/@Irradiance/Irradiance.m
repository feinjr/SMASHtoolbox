% This class creates Irradiance objects for radiometry calculations.
% Irradiance is radiation power incident on a surface.  
% The SI unit of irradiance is watts per square meter [W.m^-2].
%
% The most direct way of creating a Irradiance object is to pass 3 input
% arrays:
%    >> object=Flux(wavelength,time,data);
% The first and second inputs define the independent arrays, which are
% stored as the object's "Wavelength" and "Time" properties, respectively.
% The third  input defines dependent array and is stored as the object's
% "Data" property.  For consistency, wavelength should be a column (Mx1) 
% array, time should be a row (1xN) array, and data should be a matrix 
% (MxN) array.
%
% See also Radiation, Radiance, Flux, Exitance, Intensity
%

% created March 27, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef Irradiance < SMASH.Radiometry.Radiation
    %% properties
    properties (SetAccess={?SMASH.Radiometry.Radiation}) % core data
        
    end
    %% constructor
    methods (Hidden=true)
        function object=Irradiance(varargin)
            object=object@SMASH.Radiometry.Radiation(varargin{:});
            object.Name='Irradiance object';
            object.Title='Irradiance object';
            % handle input
            if nargin==0
                error('ERROR: No inputs')
            end
            if isempty(varargin{1})
                object.Wavelength=1;
            elseif ~isnumeric(varargin{1})
                error('ERROR: Invalid wavelength array')
            elseif iscolumn(varargin{1})
                object.Wavelength=varargin{1};
            else
                object.Wavelength=varargin{1}';
            end
            grid1Length=numel(object.Wavelength);
            if grid1Length>1
                object.DataLabel='Spectral Irradiance (W·m^{-2}·nm^{-1})';
            else
                object.DataLabel='Irradiance (W·m^{-2})';
            end
            % handle time array
            if isempty(varargin{2})
                object.Time=1;
            elseif ~isnumeric(varargin{2})
                error('ERROR: Invalid time array')
            elseif isrow(varargin{2})
                object.Time=varargin{2};
            else
                object.Time=varargin{2}';
            end
            grid2Length=numel(object.Time);
            % handle data array
            if ~isempty(varargin{3}) && isnumeric(varargin{3})
                object.Data=varargin{3};
                [mPoints,nPoints]=size(object.Data);
                if grid1Length~=nPoints||grid2Length~=mPoints
                    error('ERROR: Inconsistent data size and grid lengths')
                end
            end
        end
    end
end
    