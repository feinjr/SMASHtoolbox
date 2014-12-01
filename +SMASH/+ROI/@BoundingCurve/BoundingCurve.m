% This class defines a finite-width bounding curve in two-dimensional
% space.  Two curve directions are supported.  Horizontal curves have
% monotoically increasing x-cordinates and vertical widths.  Vertical
% curves have monotically increasing y-coordinates and horizontal widths.
%
% BoudingCurve objects are typically created with a specified direction.
%     >> object=BoudingCurve('horizontal');
%     >> object=BoudingCurve('vertical');
% The default direction is 'horizontal', and this setting can be changed
% through the Direction property. 
%     >> object.Direction='vertical';
%     >> object.Direction='horizontal';
%
% The initial bounding curve is defined to be empty.  To override this
% behavior, a Nx3 table of curve points (location, center, width) can be
% passed at object creation.
%     >> object-BoudingCurve(direction,table);
% Class methods "define", "insert, and "remove" alter the bounding curve
% after object creation.
%
% See also ROI
% 

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef BoundingCurve
    %%
    properties (SetAccess=protected)        
        Data % Boundary Data
    end
    properties
        Direction % Independent axis ('horizontal' or 'vertical')
        DefaultWidth % Default boundary width
    end
    properties
        PlotOptions = SMASH.General.PlotOptions % Default graphic options (see SMASH.General.PlotOptions)
    end
    %%
    methods (Hidden=true)
        function object=BoundingCurve(direction,data)
            % handle input
            if (nargin<1) || isempty(direction) ...
                    || strcmpi(direction,'horizontal')
                object.Direction='horizontal';
            elseif strcmpi(direction,'vertical')
                object.Direction='vertical';
            else
                error('ERROR: invalid direction');
            end            
            if nargin>=3
                object=set(object,data);
            end                              
        end
        varargout=disp(varargin);
    end   
    %% property setters
    methods
        function object=set.DefaultWidth(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid DefaultWidth value');
            object.DefaultWidth=value;
        end
    end
end