% Create Streak objects
%
% Streak objects are a special type of Image objects where one axis of
% the measurement explicitly represents time evolution.  This class expands
% the Image class, adding specialized properties and methods relevant to 
% streak cameras.
%
% Streak objects are created in a similar fashion as Image objects.
%   >> object=Streak('import',filename,format,[record]);
%
% The "streak direction" of the time axis, i.e. the streak coordinate 
% is default to 'Grid1'.  The streak direction can be changed:
%   >> object.StreakDirection='Grid2';
%
% See also ImageAnalysis, FileAccess
%

% created January 8, 2014 by Tommy Ao (Sandia National Laboratories)
%
%%
classdef Streak < SMASH.ImageAnalysis.Image
    %%
    properties
        StreakDirection='Grid1'
    end
    %% constructor
    methods (Hidden=true)
        function object=Streak(varargin)
            % handle input
            object=object@SMASH.ImageAnalysis.Image(varargin{:});
            if nargin > 0 && strcmpi(varargin{1},'restore')
                % do nothing
            else
                object.Name='Streak object';
                object.GraphicOptions.Title='Streak object';
            end
        end
    end
    %% property setters
    methods
        function object=set.StreakDirection(object,value)
            if strcmpi(value,'Grid1')
                object.StreakDirection='Grid1';
            elseif strcmpi(value,'Grid2')
                object.StreakDirection='Grid2';
            elseif isnumeric(value)
                switch value
                    case 1
                       object.StreakDirection='Grid1'; 
                    case 2
                       object.StreakDirection='Grid2';
                    otherwise
                        error('ERROR: Invalid Grid number');
                end
            else
                error('ERROR: StreakDirection must be ''Grid1'' or ''Grid2''');
            end
        end
    end
end