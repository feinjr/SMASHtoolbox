% This class creates LineVISAR objects for analyzing velocimetry data
% from a streak camera image
%
% A LineVISAR object is created:
%   >> object=LineVISAR();
%
% See also Velocimetry, Image
%

% created May 13, 2014 by Tommy Ao (Sandia National Laboratories)
%
classdef LineVISAR < SMASH.ImageAnalysis.Image
    %% properties
    properties (SetAccess={?SMASH.ImageAnalysis.Image}) % core data
        Time = []
    end
    %% constructor
    methods (Hidden=true)
        function object=LineVISAR(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:});
            if nargin > 0 && strcmpi(varargin{1},'restore')
                % do nothing
            else
                object.Name='LineVISAR object';
                object.Title='LineVISAR object';
            end
        end
    end
end