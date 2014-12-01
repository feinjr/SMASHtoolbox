% This class creates Radiance objects for radiometry calculations.
% Radiance is a measure of radiation that passes through or is emitted
% from a surface and falls within a given solid angle in a specified
% direction.  The SI unit of radiance is watts per steradian per
% square metre [W·sr^-1·m^-2].
%
% The most direct way of creating a Radiance object is to pass 3 input
% arrays:
%    >> object=Radiance(wavelength,time,data);
% The first and second inputs define the independent arrays, which are
% stored as the object's "Wavelength" and "Time" properties, respectively.
% The third  input defines the dependent array and is stored as the 
% object's "Data" property.  For consistency, wavelength should be a 
% column (Mx1) array, time should be a row (1xN) array, and data should be
% a matrix (MxN) array.
%
% To calculate the spectral radiance of black (or gray) body radiator, 
% input an empty data array, and additional temperature and emissivity 
% arrays are needed:
%    >> object=Radiance(wavelength,time,[],temperature,emissivity);
% For consistency, the temperature should be a row (1xN) array and
% the emissivity should be a column (Mx1) array.
%
% See also Radiation, Flux, Exitance, Irradiance, Intensity
%

% created March 27, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef Radiance < SMASH.Radiometry.Radiation
    %% properties
    properties (SetAccess={?SMASH.Radiometry.Radiation}) % core data
        Temperature = [] % Temperature (K)
        Emissivity = [] % Emissivity
    end
    %% constructor
    methods (Hidden=true)
        function object=Radiance(varargin)
            object=object@SMASH.Radiometry.Radiation(varargin{:});
            object.Name='Radiance object';
            object.Title='Radiance object';
            % handle input
            if nargin==0
                error('ERROR: No inputs')
            end
            % handle wavelength array
            if isempty(varargin{1})
                object.Wavelength=1;
            elseif ~isnumeric(varargin{1})
                error('ERROR: Invalid wavelength array');
            elseif iscolumn(varargin{1})
                object.Wavelength=varargin{1};
            else
                object.Wavelength=varargin{1}';
            end
            grid1Length=numel(object.Wavelength);
            object.NumberWavelengths=grid1Length;
            if grid1Length>1
                object.DataLabel='Spectral Radiance (W·sr^{-1}·m^{-2}·nm^{-1})';
            else
                object.DataLabel='Radiance (W·sr^{-1}·m^{-2})';
            end
            % handle time array
            if isempty(varargin{2})
                object.Time=1;
            elseif ~isnumeric(varargin{2})
                error('ERROR: Invalid time array');
            elseif isrow(varargin{2})
                object.Time=varargin{2};
            else object.Time=varargin{2}';
            end
            grid2Length=numel(object.Time);
            object.NumberTimes=grid2Length;
            % handle data array
            if isempty(varargin{3})
                % handle temperature array
                if ~isempty(varargin{4}) && isrow(varargin{4})
                    object.Temperature=varargin{4};
                else
                    object.Temperature=varargin{4}';
                end
                tempLength=numel(object.Temperature);
                if grid2Length~=tempLength
                    error('ERROR: Invalid temperature array')
                end
                % handle emissivity array
                if ~isempty(varargin{5}) && iscolumn(varargin{5})
                    object.Emissivity=varargin{5};
                else
                    object.Emissivity=varargin{5}';
                end
                emisLength=numel(object.Emissivity);
                if grid1Length~=emisLength
                    error('ERROR: Invalid emissivity array')
                end
                % calculate radiance data using planck's law
                radiance=zeros(grid1Length,grid2Length);
                for n=1:grid2Length
                    radiance(:,n)=planck(object.Wavelength,...
                        object.Temperature(n),object.Emissivity);
                end
                object.Data=radiance;
            elseif ~isempty(varargin{3}) && isnumeric(varargin{3})
                object.Data=varargin{3};
                [mPoints,nPoints]=size(object.Data);
                if grid1Length~=nPoints||grid2Length~=mPoints
                    error('ERROR: Inconsistent data size and grid lengths')
                end
            end
        end
    end
end
    