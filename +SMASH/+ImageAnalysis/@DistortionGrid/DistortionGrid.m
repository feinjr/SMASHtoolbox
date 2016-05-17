% This class is a specialized form of the Image class, with specialized
% capabilities for characterizing and removing geometric distortion.
% UNDER CONSTRUCTION
%
% See also ImageAnalysis
%

%
%
%
classdef DistortionGrid 
    properties
        Measurement % Measured distortion grid (Image object)
    end    
    %%
    properties (SetAccess=protected)        
        IsoPoints = [] % (x,y) table of IsoPoints, NaN separators between groups
        IsoMesh1 = [] % Mesh constructed from IsoPoints (Grid1 values)
        IsoMesh2 = [] % Mesh constructed from IsoPoints (Grid2 values)
        ArcMesh1 = [] % Undistored mesh (Grid1 values)
        ArcMesh2 = [] % Undistored mesh (Grid2 values)
    end
    %%
    methods (Hidden=true)
        function object=DistortionGrid(varargin)
            if nargin==0
                temp=SMASH.ImageAnalysis.Image();
                object=SMASH.ImageAnalysis.DistortionGrid(temp);
            elseif strcmpi(varargin{1},'-empty')
                % do nothing
            elseif ischar(varargin{1})
                [~,~,ext]=fileparts(varargin{1});
                if strcmp(ext,'.sda')
                    temp=SMASH.FileAccess.readFile(varargin{:});                    
                else
                    temp=SMASH.ImageAnalysis.Image(varargin{:});
                end
                try
                    object=SMASH.ImageAnalysis.DistortionGrid(temp);
                catch
                    error('ERROR: unable to construct object from SDA record');
                end
            elseif isobject(varargin{1})
                switch class(varargin{1})
                    case 'SMASH.ImageAnalysis.Image'
                        object.Measurement=varargin{1};
                        object=create(object);                                
                    case 'SMASH.ImageAnalysis.DistortionGrid'
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
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    methods (Access=protected, Hidden=true)
        varargout=mesh(varargin)
        varargout=remesh(varargin)
        varargout=blurLocal(varargin)
        varargout=blurGlobal(varargin)
    end
end