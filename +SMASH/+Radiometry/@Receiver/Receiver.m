% This class creates Receiver objects for radiometry calculations.
% Radiation incident on a surface may come from different directions, and 
% the manner in which the surface responds to this radiation depends on 
% the direction.  The irradiance and radiant flux of a receiver are 
% determined.
%
% The most direct way of creating a Receiver object is to pass 3 input
% arrays:
%    >> object=Receiver(wavelength,time,data);
% The first and second inputs define the independent arrays, which are
% stored as the object's "Wavelength" and "Time" properties, respectively.
% The third  input defines the dependent array and is stored as the 
% object's "Data" property.  For consistency, wavelength should be a 
% column (Mx1) array, time should be a row (1xN) array, and data should be
% a matrix (MxN) array.
%
% See also Radiation, Emitter
%

% created March 27, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef Receiver < SMASH.Radiometry.Radiation
    %% properties
    properties (SetAccess={?SMASH.Radiometry.Radiation}) % core data

    end
    %% constructor
    methods (Hidden=true)
        function object=Receiver(varargin)
            object=object@SMASH.Radiometry.Radiation(varargin{:});
            object.Name='Receiver object';
            object.Title='Receiver object';
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
        end
    end
end
    