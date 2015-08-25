% UNDER CONSTRUCTION


%%
classdef StepWedge
    %%
    properties
        Measurement % Step wedge measurment (Image object)
        StepLevels = [0.08 0.20 0.35 0.51 0.64 0.78 0.94 ...
            1.12 1.25 1.39 1.54 1.67 1.82 1.98 ...
            2.15 2.29 2.43 2.59 2.76 2.91 3.02];% step wedge levels
        StepOffsets = [0 2]; % step wedge offset (levels repeated)
        CalibrationRange=[0.025 0.975]; % allowed calibration range
        DerivativeParams=[1 9]; % Derivative parameters ([order size]) for step detection
        RegionTable=[]; % Region of interest table ([x0 y0 Lx Ly])
        HorizontalMargin=0.20; % 
        VerticalMargin=0.10; % 
        TransferTable=[];
    end
    %% constructor
    methods (Hidden=true)
        function object=StepWedge(varargin)
            if nargin==0
                temp=SMASH.ImageAnalysis.Image();
                object=SMASH.ImageAnalysis.StepWedge(temp);
            elseif strcmpi(varargin{1},'-empty')
                % do nothing
            elseif ischar(varargin{1})
                [~,~,ext]=fileparts(varargin{1});
                if strcmp(ext,'.sda')
                    temp=SMASH.FileAccess.readFile(varargin{:});
                    try
                        object=SMASH.ImageAnalysis.StepWedge(temp);
                    catch
                        error('ERROR: unable to construct object from SDA record');
                    end
                else
                    object.Measurement=SMASH.ImageAnalysis.Image(varargin{:});
                end
            elseif isobject(varargin{1})
                switch class(varargin{1})
                    case 'SMASH.ImageAnalysis.Image'
                        object.Measurement=varargin{1};
                        object.Measurement.GraphicOptions.Title='Step wedge';                       
                    case 'SMASH.ImageAnalysis.StepWedge'
                        object=varargin{1};
                    otherwise
                        error('ERROR: unable to contruct object from this input');
                end
            else
                error('ERROR: unable to contruct object from this input');
            end
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% setters
    methods
        function object=set.StepLevels(object,value)
            assert(isnumeric(value) & numel(value)>1 & all(value>0),...
                'ERROR: invalid StepLevels value');
            if numel(value) ~= numel(object.StepLevels)
                warning('SMASH:Wedge','Number of step levels was changed');
            end
            value=reshape(value,[1 numel(value)]);
            value=sort(value);
            object.StepLevels=value;
        end
        function object=set.StepOffsets(object,value)
            assert(isnumeric(value) & numel(value)>0 & all(value>=0),...
                'ERROR: invalid StepOffsets value');
            if numel(value) ~= numel(object.StepOffsets)
                warning('SMASH:Wedge','Number of step offsets was changed');
            end
            value=reshape(value,[1 numel(value)]);
            value=sort(value);
            object.StepOffsets=value;
        end
        function object=set.CalibrationRange(object,value)
            if isempty(value)
                value=[0.025 0.975];
            end
            assert(isnumeric(value) & numel(value==2) ...
                & all(value>0) & all(value<1),...
                'ERROR: invalid CalibrationRange value');
            value=sort(value);
            object.CalibrationRange=value;
        end
        function object=set.DerivativeParams(object,value)
            if isempty(value)
                value=[1 9];
            end
            assert(isnumeric(value) & numel(value==2) ...
                & all(value>0),...
                'ERROR: invalid DerivativeParams value');
            object.DerivativeParams=value;
        end
    end
end