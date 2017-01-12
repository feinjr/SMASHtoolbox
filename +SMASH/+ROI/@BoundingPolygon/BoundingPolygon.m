% UNDER CONSTRUCTION
classdef BoundingPolygon
properties (SetAccess=protected)        
        Data % Boundary Data
    end
    properties
        Label = 'Boundary polygon' % Text label
        ColumnLabel = {'x' 'y'} % Table column labels
        GraphicOptions % Graphic options
    end
    methods (Hidden=true)
        function object=BoundingPolygon()
            
        end
    end
    
    
end