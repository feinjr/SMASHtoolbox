% This class describes curves as a sequence of line segments.  In this
% context, a "curve" is any ordered group of points in a two-column array
% ([x y]).  Each row of the array corresponds to one point on the curve.
%
% LineSegments2D objects are created with a points array.
%     >> object=LineSegments2D(array);
% The points array of an object can be read from the Points property:
%     >> data=object.Point;
% but cannot be changed directly.  Modifications may be performed through
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
classdef LineSegments2D
    %%
    properties (SetAccess=protected)
        Points % Point coordiantes (two-column array)
        Segments % Segment data (three dimensional array)
    end
    properties
        GraphicOptions=SMASH.General.GraphicOptions('Marker','none') % Graphic options object
        BoundaryType='projected' % Boundary type: ['projected'], 'closed', or 'wrapped'
    end
    properties (SetAccess=protected,Hidden=true)
        NumberPoints
        NumberSegments      
    end
    %%
    methods (Hidden=true)
        function object=LineSegments2D(varargin)
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
    %% restore method allows objects to be restored from SDA files
     methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.MonteCarlo.Support.LineSegments2D();
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
end