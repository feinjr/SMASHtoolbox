% This class is a specialized form of the Image class, with specialized
% capabilities for characterizing and removing geometric distortion.
% Distortion objects are created like any other Image object, usually by
% importing information from a data file.
%    >> object=Distortion('import',filename,format,[record]);
% Groups of fixed position, or isopoints, may be selected with the "locate"
% method.
%    >> object=locate(object);
% Isopoints are used to create an isomesh, a rectangular array of positions
% that would be aligned in the absence of geometric distortion.  This mesh
% can be smoothed with the "blur" method:
%    >> object=blur(object);
% and displayed graphically with the "visualize" method.
%    >> visualize(object,[mode]);
% The "apply" method uses the isomesh of a Distortion object to remove
% distortion in another Image object.
%    >> result=apply(object,target);
% Refer to method-specific help for more information.
%
% See also ImageAnalysis, FileAccess.SupportedFormats
%

%
% created January 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef Distortion < SMASH.ImageAnalysis.Image
    %%
    properties (SetAccess=?SMASH.General.DataClass)        
        IsoPoints = [] % (x,y) table of IsoPoints, NaN separators between groups
        IsoMesh1 = [] % Mesh constructed from IsoPoints (Grid1 values)
        IsoMesh2 = [] % Mesh constructed from IsoPoints (Grid2 values)
        ArcMesh1 = [] % Undistored mesh (Grid1 values)
        ArcMesh2 = [] % Undistored mesh (Grid2 values)
    end
    %%
    methods (Hidden=true)
        function object=Distortion(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:});
            if (nargin>0) && strcmpi(varargin{1},'restore')
                % do nothing
            else
                object.Name='Distortion object';
                object.Grid1Label='Grid1';
                object.Grid2Label='Grid2';
                object.DataLabel='Data';      
            end       
            object=concealMethod(object,...
                'bin');
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
    methods (Access=protected, Hidden=true)
        varargout=mesh(varargin)
        varargout=remesh(varargin)
        varargout=blurLocal(varargin)
        varargout=blurGlobal(varargin)
    end
end