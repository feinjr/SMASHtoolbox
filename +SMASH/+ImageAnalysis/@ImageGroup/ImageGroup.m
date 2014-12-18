% UNDER CONSTRUCTION
%
% object=ImageGroup(x,y,z);

classdef ImageGroup < SMASH.ImageAnalysis.Image
    %%
    properties (SetAccess=?SMASH.General.DataClass)
        NumberImages = 0 % Number of signals
    end
    %% hidden methods
    methods (Hidden=true)
        function object=ImageGroup(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:}); % call superclass constructor
        end
    end
    %% protected methods
    methods (Access=protected)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    
    
end