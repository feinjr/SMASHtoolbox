% This class describes curves as a sequence of line segments.  In this
% context, a "curve" is an ordered group of points arranged in a
% two-dimensional array.  The number of columns in this array describes the
% curve's dimensionality, e.g. a curve in the (x,y) plane is defined by a
% table with two columns.  Each row of the array corresponds to a single
% point on the curve.  
%
% LineSegments objects are created with a points array.
%     >> object=LineSegments(array);
% At present, the class supports to two-dimensional curves only.  The
% points array of an object can be read from the Points property:
%     >> data=object.Point;
% but cannot be changed directly.  Modifications may be performed through
% the add, remove, and reset methods.
%
% Curves are single-valued functions of one independent variable.  This
% variable is implicitly linked to the row index of the points array;
% explicit specification is not required.  For example, a two-dimensional
% curve is a set of dependent variables x(t) and y(t), where t might
% represent time, arc length, or some other monotonically increasing
% variable.  Curves are *not* limited to single-valued relationships
% between dimensions, such as y(x).
%
% Segments are linear connections between adjacent points on a curve.  
% Consider a two-dimensional curve defined by three points.
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
% See also Graphics
%

%
% created October 22, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef LineSegments
    %%
    properties (SetAccess=protected)
        Points % 2D array of point coordinates
        Segments % 3D array of segment data
    end
    properties
        GraphicOptions=SMASH.General.GraphicOptions() % Graphic options object
        BoundaryType='projected' % Boundary type: ['projected'], 'closed', or 'wrapped'
    end
    properties (SetAccess=protected,Hidden=true)
        NumberPoints
        NumberDimensions
        NumberSegments      
    end
    %%
    methods (Hidden=true)
        function object=LineSegments(varargin)
            object=reset(object,varargin{:});
        end
        varargout=create(varargin);
    end
    %%
    methods 
        function object=set.BoundaryType(object,value)
            assert(ischar(value),'ERROR: invalid BoundaryType setting');
            value=lower(value);
            switch value
                case {'closed','projected','wrapped'}
                    % valid choices
                otherwise
                    error('ERROR: invalid BoundaryType setting');
            end
            object.BoundaryType=value;
            object=reset(object);
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
end