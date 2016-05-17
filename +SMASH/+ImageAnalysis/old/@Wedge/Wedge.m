% Create Wedge objects
%
% WARNING: this class is obsolete and will be removed in the future.  Use
% the StepWedge class instead.
%
% Wedge objects are a special type of Image objects designed for
% characterizing and removing nonlinear response such as film exposure.
%
% Wedge objects are created in a similar fashion as Image objects.
%   >> object=Wedge('import',filename,format,[record]);
%
% First, analyze the Wedge object to determine the transfer table of film
% exposure to linearized intensity:
%   >> object=analyze(object);
%
% Next, apply the Wedge transfer table (object) to an Image (target):  
%   >> target=apply(object,target);
%
% See also ImageAnalysis, FileAccess.SupportedFormats
%

% created January 8, 2014 by Tommy Ao (Sandia National Laboratories)
% revised March 2, 2015 by Daniel Dolan
%   -added StepLevels, StepOffets, and Calibration properties to provide
%   control of the analysis method
%%
classdef Wedge < SMASH.ImageAnalysis.Image
    %%
    properties (SetAccess={?SMASH.General.DataClass})
        TransferTable % transfer table (Mx2 array)
    end
    properties
        StepLevels = [0.08 0.20 0.35 0.51 0.64 0.78 0.94 ...
            1.12 1.25 1.39 1.54 1.67 1.82 1.98 ...
            2.15 2.29 2.43 2.59 2.76 2.91 3.02];% step wedge levels
        StepOffsets = [0 2]; % step wedge offset (levels repeated)
        CalibrationRange=[0.025 0.975]; % allowed calibration range
    end
    %% constructor
    methods (Hidden=true)
        function object=Wedge(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:}); 
            message={};
            message{end+1}='This class is obsolete and will be removed in the future';
            message{end+1}='Use the StepWedge class instead';
            warning('SMASH:Wedge','%s\n',message{:});
        end
    end
    %%
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
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
    end
end