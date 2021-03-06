% This class creates objects for performing the transfer function window
% correction to velocimetry data
%
% The default VelocityTransfer object is created without input:
%
%     >> object=VelocityTransfer()
%
% This provides 3 consective interactive windows to select the experimental
% window velocity, simulated window velocity, and simulated in situ
% velocity in that order. 
%
% Alternatively, the velocities can be specified directly:
%
%     >> object=VelocityTransfer('experimentalWindow.dat','simulatedWindow.dat','simulatedInsitu.dat')
%
% or restored from an sda file;
%
%     >> object=VelocityTransfer('file.sda')
%
% See also DynamicMaterials, SignalAnalysis.Signal

%
% created March 26, 2015 by Justin Brown (Sandia National Laboratories)
%
classdef VelocityTransfer
    %%
    properties
        MeasuredWindow     % Experimental window velocity (signal object)
        SimulatedWindow    % Simulated window velocity (signal object)
        SimulatedInsitu    % Simulated in situ velocity (signal object)
        Settings           % Analysis settings (structure)
    end
    properties (SetAccess=protected)
        %Preview  % Preview results (Image object)
        Results  % Analysis results (signal object)           
    end
    %%
    methods (Hidden=true)
        function object=VelocityTransfer(varargin)
            % default settings
            p=struct();
            p.PowerScale = 1;
            p.NumberPoints = 2000; %Number of points to use in normalzing
            p.WindowTimes = []; %Array of causal window times
            p.InsituTimes = []; %Array of corresponding insitu times
            object.Settings=p;
            
            % manage input
            if (nargin==0)               
                % Select experimental window velocity
                [filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
                'Measured Window Velocity', 'MultiSelect', 'off');
                object.MeasuredWindow = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename),'column');
                object.MeasuredWindow.Name=filename;
                                
                % Select simulated window velocity
                [filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
                'Simulated Window Velocity', 'MultiSelect', 'off');
                object.SimulatedWindow = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename),'column');
                object.SimulatedWindow.Name=filename;
                
                % Select simulated in situ velocity
                [filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
                'Simulated InSitu Velocity', 'MultiSelect', 'off');
                object.SimulatedInsitu = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename),'column');
                object.SimulatedInsitu.Name=filename;
   
            elseif (nargin==3 & ischar(varargin{1}) & ischar(varargin{2}) & ischar(varargin{3}))
                object.MeasuredWindow = SMASH.SignalAnalysis.Signal(varargin{1},'column');
                object.SimulatedWindow = SMASH.SignalAnalysis.Signal(varargin{2},'column');
                object.SimulatedInsitu = SMASH.SignalAnalysis.Signal(varargin{3},'column');
            elseif (nargin==1 & ischar(varargin{1}))
                object=SMASH.FileAccess.readFile(varargin{1});
            else
                object.MeasuredWindow = SMASH.SignalAnalysis.Signal(0,0);
                object.MeasuredWindow = SMASH.SignalAnalysis.Signal(0,0);
                object.MeasuredWindow = SMASH.SignalAnalysis.Signal(0,0);
            end
            object.MeasuredWindow.GridLabel='Time';
            object.MeasuredWindow.DataLabel='Velocity';
            object.MeasuredWindow.GraphicOptions.LineColor=[0.0 0.0 0.0]; % back
            object.SimulatedWindow.GraphicOptions.LineColor=[1.0 0.0 0.0]; % red
            object.SimulatedInsitu.GraphicOptions.LineColor=[0.0 0.0 1.0]; % blue
            
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end   
end