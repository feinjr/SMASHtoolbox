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
        TransferTable
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
end