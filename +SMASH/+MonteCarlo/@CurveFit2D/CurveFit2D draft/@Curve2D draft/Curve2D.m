% UNDER CONSTRUCTION
%
%   object=Curve2D(model,param,domain)
% Model function is evalutated in the specified domain (xmin/xmax and
% ymin/ymax)
%

% This class describes curves as a sequence of line segments between points
% on a two-dimensional plane. These points are specified in a two-column
% table ([x y]).  Each row of the array defines one point on the curve.

%
% Curve2D objects are created with a points table.
%     >> object=Curve2D(array);
% The points array can be read from the Points property:
%     >> data=object.Point;
% but cannot be changed directly.  Modifications can be performed through
% the add, remove, and reset methods.
%
% Curves are single-valued functions of one independent variable.  This
% variable is implicitly linked to the row index of the points array.
% Conceptually, x=x(t) and y=y(t) where t might represent time, arc length,
% or some other monotonically increasing variable.  Explicit specification
% of this variable or it's link to row index is *not* required.
%
% Segments are linear connections between adjacent points on a curve.  
% Consider a curve defined by three points.
%     point 1: (0,0)
%     point 2: (1,0)
%     point 3: (1,1)
%     array=[0 0; 1 0; 1 1;]
% These points define two line segments.
%     segment 1: (0,0) -> (1,0)
%     segment 2: (1,0) -> (1,1)
% This example illustrates a continous curve, where each segments are
% generated from each row pair.  Discontinuties may be introduced by placed
% NaN values in the points array.  For example, the array:
%     [0 0; 1 0; nan nan; 1 1; 0 1;]
% defines two unconnected segments.  Segment information is stored in the
% Segments propery (read only).
%
% Curve boundaries may be handled in several modes
%     -By default, curves are linearly projected beyond the first and last
%     point as needed ('projected' mode).
%     -Curves may be confined to the specified points with 'closed' mode.
%     -The last point of the curve may be automatically connected to the
%     first point with 'wrapped' mode.
% Boundary modifications are made through the BoundaryType property.
%     >> object.BoundaryType=mode;
% Changing boundary types may alter the Segments property, epsecially when
% switching between 'wrapped' and 'projected'/'closed' modes.
%

%
% created October 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef Curve2D
    %%
    properties (SetAccess=protected)
        Parameter
        BoundaryType='projected' % Boundary type: ['projected'], 'closed', or 'wrapped'
        Points % Evaluation point coordinates [x y] (two-column table)
    end
    properties
        GraphicOptions=SMASH.General.GraphicOptions('Marker','none') % Graphic options object        
    end    
    %%
    methods (Hidden=true)
        function object=Curve2D(varargin)
            object=reset(object,varargin{:});
        end
        varargout=reset(varargin);
    end   
    %% restore method allows objects to be restored from SDA files
     methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.MonteCarlo.CurveFit2D.Curve2D();
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
end