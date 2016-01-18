% This class creates Radiography objects from ZBL backlighter image plate
% records.  It is a subclass of SMASH.ImageAnalysis.Image
%
% A Radiography object is created:
%   >> object=Radiography();
%
% See also Xray, Image
%
%
% created May 27, 2014 by Patrick Knapp (Sandia National Laboratories)
%
classdef Radiography < SMASH.ImageAnalysis.Image
    %% properties
    properties (SetAccess={?SMASH.DataClass}) % core data
    
    end
    
    properties
        Magnification1 = 5.9642;
        Magnification2 = 5.7736;
        Shot = 9999;
        Frame = [];
        Time = [];
        PhotonEnergy = 6151; %Standard ZBL Backlighter Energy
        Opacity = 2.2392; % Be Opacity
        
    end
    %% constructor
    methods (Hidden=true)
        function object=Radiography(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:});
            if nargin > 0 && strcmpi(varargin{1},'restore')
                % do nothing
            else
                object.Name='Radiography object';
            end
        end
    end
    %%
    methods (Hidden=false)
        varargout=Transmission(varargin)
        varargout=BackgroundSubtraction(varargin)
        varargout=svd_surface(varargin)
        varargout=AbelInvert(varargin)
    end
end