% This class creates and manages axes insets, which are useful for
% highlighting details in a plot.
%
% Insets are generated from a bounded region of a source axes.  A rectangle
% is drawn on the source axes to indicate the inset bounds, and all
% graphical content in these bounds is reproduced in a separte (inset) axes.
% Horizontal/vertical boundaries are specified in axes units; inset axes
% position is specified in normalized units (with respect to the source
% axes).
%

%
% created January 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
classdef AxesInset < handle
    %%
    properties (SetAccess = protected)
        Source % Source axes handle
        Inset % Inset axes handle
        Rectangle % Inset rectangle handle
    end
    properties
        XBound % Horizontal bounds
        YBound % Vertical bounds
        Position = [0.70 0.05 0.25 0.2] % normalized inset position
    end
    %%
    methods (Hidden=true)
        function object=AxesInset(varargin)
            object=processInput(object,varargin{:});                                   
            update(object);
        end
    end
    %%
    methods
        function delete(object)            
            if ishandle(object.Inset)
                delete(object.Inset);
            end            
            if ishandle(object.Rectangle)
                delete(object.Rectangle)
            end            
        end
    end
    %% setters
    methods
        function set.XBound(object,value)
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: invalid XBound value');
            value=sort(value);
            assert(diff(value)>0,'ERROR: invalid XBound value');
            object.XBound=value;
        end
        function set.YBound(object,value)
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: invalid YBound value');
            value=sort(value);
            assert(diff(value)>0,'ERROR: invalid YBound value');
            object.YBound=value;
        end
        function set.Position(object,value)
            assert(isnumeric(value) && numel(value)==4,...
                'ERROR: invalid Position value');
            assert(all(value(3:4)>0),'ERROR: invalid Position value');
            object.Position=value;
        end
    end
end

%%
function object=processInput(object,varargin)

% determine source handle
if (nargin<2) || ischar(varargin{1})
    object.Source=gca;
elseif ishandle(varargin{1})
    type=get(varargin{1},'Type');
    assert(strcmpi(type,'axes'),'ERROR: invalid source handle');
    object.Source=varargin{1};
    varargin=varargin(2:end);
else
    error('ERROR: invalid source handle');
end

% process options
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

object.XBound=xlim(object.Source);
object.YBound=ylim(object.Source);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid property name');
    name=lower(name);
    value=varargin{n+1};
    switch name
        case {'xbound' 'xlim'}
            object.XBound=value;
        case {'ybound' 'ylim'}
            object.YBound=value;
        case 'position'
            object.Position=value;
        otherwise
            fprintf('Ignoring unrecognized name "%s"\n',name);
    end
end

end