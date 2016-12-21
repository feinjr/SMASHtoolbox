% This class creates objects for analyzing Velocity Interferomtry for Any
% Reflector (VISAR) signals.  
%
% The class accepts three types of VISAR measurements distinguished by the
% number of signals loaded.
%      >> Fast Push-Pull - There are 4 signals with an assumed order of D1A,
%                         D2A, D1B, and D2B
%      >> Conventional - There are 3 signals with an assumed order of
%                        DX, DY, and BIM
%      >> Standard Push-Pull - There are 2 signals with an assumed order
%                              of DX and DY
%
% Currently, this class only loads in a single file containing all
% channels. It does not support loading in multiple files representing each
% channel.
%
% created March 7th, 2016 by Paul Specht (Sandia National Laboratories)
% Updated December 21 2016 by Paul Specht (Sandia National Laboratories)

classdef VISAR
    %%
    properties
        Measurement % Recorded Signals (SignalGroup object)
        Label = 'New Signal';
        Notes = '';
        TimeShifts=[];
        VerticalOffsets=[];
        VerticalScales=[];
        VPF=1;
        Wavelength=532e-9;
        InitialVelocity=0;
        EllipseParameters=[0 0 1 1 0];
        ReferenceRegion = [] % Reference ROI boundaries
        ExperimentalRegion = [] % Reference ROI boundaries
        Jumps = [] %cell array of fringe jumps
    end
    properties (SetAccess = protected)
        Processed % Preprocessed Signals (SignalGroup Object)
        Quadrature %Quadrature Signals (SingalGroup Object)
        FringeShift %Fringe Shift (Signal object)
        Contrast  %Contrast (Signal object)
        Velocity % Converted Velocity results (Signal object)
        Displacement % Converted Displacement results (Signal object)
    end
    properties (Dependent)
        Type
    end
    %%
    methods (Hidden=true)
        function object=VISAR(varargin)
            % manage input
            if (nargin==1) && isobject(varargin{1})
                varargin{1}=SMASH.SignalAnalysis.SignalGroup(varargin{1});
                object.Measurement=varargin{1};
            elseif (nargin>0) && ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{:});
                switch class(temp)
                    case 'SMASH.Velocimetry.VISAR'
                        object=temp;
                    otherwise
                        object.Measurement=SMASH.SignalAnalysis.SignalGroup(varargin{:});
                end
            else
                object.Measurement=SMASH.SignalAnalysis.SignalGroup(varargin{:});
            end
            object.ReferenceRegion=[object.Measurement.Grid(1) object.Measurement.Grid(2)];
            object.ExperimentalRegion=[object.Measurement.Grid(1) object.Measurement.Grid(end)];
            object.Measurement.Name='VISAR Measurement';
            object.Measurement.GraphicOptions.Title='VISAR Measurement';
            assert(object.Measurement.NumberSignals ~= 1,...
                'ERROR: Measurement Must be a RAW VISAR Signal With at Least 2 Signals');
            if object.Measurement.NumberSignals > 4
                object.Measurement=object.Measurement.Data(:,1:4);
            end
        end
        varargout=process(varargin);
        varargout=analyze(varargin);
        varargout=analyzeFourier(varargin);
        varargout=adjustEllipse(varargin);
        varargout=offset(varargin);
        varargout=adjustFringes(varargin);
        varargout=export(varargin);
        varargout=saveSettings(varargin);
        varargout=loadSettings(varargin);
    end
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.SignalGroup'),...
                'ERROR: Measurement Property Must be a SignalGroup Object');
            object.Measurement=value;
            assert(object.Measurement.NumberSignals ~= 1,...
                'ERROR: Measurement Must be a RAW VISAR Signal With at Least 2 Signals');
            if object.Measurement.NumberSignals > 4
                object.Measurement=object.Measurement.Data(:,1:4);
            end
        end
        function value = get.Type(object)
            n=object.Measurement.NumberSignals;
            if n == 4
                value='Fast Push-Pull';
            elseif n == 3
                value='Conventional';
            else
                value='Standard Push-Pull';
            end
        end
        function object=set.TimeShifts(object,value)
            assert(isnumeric(value),...
                'ERROR: Time Shifts Must be Numeric');
            if (size(value,1) == 1) || (size(value,2) == 1)
                object.TimeShifts=value;
            else
                error('ERROR: Time Shifts Must be An Array');
            end
        end
        function object=set.VerticalOffsets(object,value)
            assert(isnumeric(value),...
                'ERROR: Vertical Offsets Must be Numeric');
            if (size(value,1) == 1) || (size(value,2) == 1)
                object.VerticalOffsets=value;
            else
                error('ERROR: Vertical Offsets Must be An Array');
            end
        end
        function object=set.VerticalScales(object,value)
            assert(isnumeric(value),...
                'ERROR: Vertical Scales Must be Numeric');
            if (size(value,1) == 1) || (size(value,2) == 1)
                object.VerticalScales=abs(value);
            else
                error('ERROR: Vertical Scales Must be An Array');
            end
        end
        function object=set.VPF(object,value)
            assert(isnumeric(value),...
                'ERROR: VPF Must be Numeric');
            if numel(value) > 1
                object.VPF=abs(value(1,1));
            else
                object.VPF=abs(value);
            end
        end
        function object=set.Wavelength(object,value)
            assert(isnumeric(value),...
                'ERROR: Wavelength Must be Numeric');
            if numel(value) > 1
                object.Wavelength=abs(value(1,1));
            else
                object.Wavelength=abs(value);
            end
        end
        function object=set.InitialVelocity(object,value)
            assert(isnumeric(value),...
                'ERROR: Initial Velocity Must be Numeric');
            if numel(value) > 1
                object.InitialVelocity=value(1,1);
            else
                object.InitialVelocity=value;
            end
        end
        function object=set.EllipseParameters(object,value)
            assert(isnumeric(value),...
                'ERROR: Ellipse Parameters Must be Numeric');
            assert((numel(value) == 5),...
                'ERROR: 5 Ellipse Parameters are Needed');
            object.EllipseParameters=value;
        end
        function object=set.ReferenceRegion(object,value)
            assert(isnumeric(value),...
                'ERROR: Reference ROI Bounds Must be Numeric');
            assert((numel(value) == 2),...
                'ERROR: 2 Reference ROI Bounds are Needed');
            object.ReferenceRegion=sort(value);
        end
        function object=set.ExperimentalRegion(object,value)
            assert(isnumeric(value),...
                'ERROR: Experimental ROI Bounds Must be Numeric');
            assert((numel(value) == 2),...
                'ERROR: 2 Experimental ROI Bounds are Needed');
            object.ExperimentalRegion=sort(value);
        end
        function object=set.Jumps(object,value)
            assert(isnumeric(value),...
                'ERROR: Fringe Jumps Must be Numeric');
            assert((size(value,2) == 3),...
                'ERROR: Each Fringe Jump Must have Three Parameters in Separate Columns [add/sub time width]');
            for k=1:size(value,1)
                value(k,1)=sign(value(k,1));
            end
            object.Jumps=value;
        end
    end
end