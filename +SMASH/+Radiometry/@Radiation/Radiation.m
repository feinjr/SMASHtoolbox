% This class creates Radiation objects for analyzing the electromagnetic 
% radiant power that all matter emits, also referred to as radiometry.  
% The objective of radiometry is to characterize the distribution of the 
% radiation's power in space and time.  A typical radiometric analysis 
% would to be determine the amount of radition leaving one surface within 
% a specified spectral region and in a given direction reaches another 
% surface.
% 
% Key radiation quantities are:
%   1. Radiant Flux:        total power of radiation emitted from a source, 
%                           or the total power landing on a particular 
%                           surface, [W].
%   2. Spectral Flux:       radiant flux per wavelength (nm) [W.nm^-1]
%   3. Radiance:            total radiation that passes through or is 
%                           emitted from a surface and falls within a given
%                           solid angle in a specified direction, 
%                           [W.sr^-1.m^-2].
%   4. Spectral Radiance:   radiance per wavelength [W.sr^-1.m^-2.nm^-1].
%     
% Other radiation quantities such as radiant energy, radiant intensity, 
% irradiance, exitance, etc. are calculated from the above key radiation 
% quantities.
%
% See also Radiometry
%

% created March 27, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef Radiation < SMASH.General.DataClass
    %% properties
    properties (SetAccess={?SMASH.General.DataClass}) % core data
        Source = 'MATLAB array' % MATLAB array/operation, file name
        SourceFormat = '' % Source format (import/restore only)
        SourceRecord = '' % Source record (restore only)
        Wavelength = [] % Independent wavelength (Grid1) array
        Time = [] % Independent time (Grid2) array
        Theta = [] % Zenith angle 
        LimitIndex1='all' % Region of interest on Grid1
        LimitIndex2='all' % Region of interest on Grid2
        NumberWavelengths = [] % Number of wavelength points
        NumberTimes = [] % Number of time points
    end
    properties % display-related settings
        WavelengthLabel='Wavelength (nm) ' % XLabel used by view
        TimeLabel='Time (ns) ' % YLabel used by view
        Title='Radiation object' % Title used by view
        DataLim='auto' % Data range used by view
        DataScale='linear' % Data scaling used by view
        LineColor='m' % Line color used in view
        LineStyle='-' % Line style used in view
        LineWidth=0.5 % Line width used in view
        Marker='.' % Marker used in view, slice
        MarkerSize= 5 % Marker size used in view
        ColorMap=jet(64) % Colormap used in view
        AspectRatio = 'auto' % Aspect ratio used in view
        Legend={}; % Legend used by view
    end
        %% constructor
        methods (Hidden=true)
            function object=Radiation(varargin)
                object.Name='Radiation object';
                object=concealProperty(object,'SourceFormat','SourceRecord',...
                    'LineColor','LineStyle','LineWidth',...
                    'ColorMap','DataLim',...
                    'Marker','MarkerSize','Precision',...
                    'LimitIndex1','LimitIndex2');
            end
        end
end
    