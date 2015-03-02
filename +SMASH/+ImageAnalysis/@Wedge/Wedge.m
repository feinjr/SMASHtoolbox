% Create Wedge objects
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
%
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
        StepOffset = [0 2.13]; % step wedge offset (levels repeated)
    end
    %% constructor
    methods (Hidden=true)
        function object=Wedge(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:});            
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
        function object=set.StepOffset(object,value)
            assert(isnumeric(value) & numel(value)>0 & all(value>=0),...
                'ERROR: invalid StepOffset value');
            if numel(value) ~= numel(object.StepOffset)
                warning('SMASH:Wedge','Number of step offsets was changed');
            end
            value=reshape(value,[1 numel(value)]);
            value=sort(value);
            object.StepOffset=value;
        end
    end
end