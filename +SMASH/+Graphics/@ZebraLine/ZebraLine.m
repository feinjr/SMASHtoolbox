% Basic zebra line class
classdef ZebraLine < hgsetget
    %%
    properties
        Parent
        XData
        YData
        ForegroundColor = 'black'
        ForegroundStyle = '--'
        BackgroundColor = 'white'        
        LineWidth = 0.5
        Visible = 'on'
    end
    properties (SetAccess=protected)
        Group
    end
    %%
    methods (Hidden=true)
        function object=ZebraLine(varargin)
            % handle input
            assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');
            for n=1:2:nargin
                name=varargin{n};
                assert(isprop(object,name),'ERROR: invalid property name');
                object.(name)=varargin{n+1};
            end
            if isempty(object.Parent)
                object.Parent=gca;
            end
            % create graphics
            object.Group=hggroup('Visible','off');
            line('Parent',object.Group,'Tag','Background');
            line('Parent',object.Group,'Tag','Foreground');
            update(object);
        end
    end
    %%
    methods
        function set.Parent(object,value)
            assert(ishandle(value),'ERROR: invalid Parent value');
            object.Parent=value;
            update(object)
        end
        function set.XData(object,value)
            assert(isnumeric(value),'ERROR: invalid XData value');
            object.XData=value;
            update(object);
        end
        function set.YData(object,value)
            assert(isnumeric(value),'ERROR: invalid YData value');
            object.YData=value;
            update(object);
        end
        function set.ForegroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.ForegroundColor=value;
            update(object);
        end
        function set.ForegroundStyle(object,value)
            switch value
                case {'--',':','-.'}
                    object.ForegroundStyle=value;
                otherwise
                    error('ERROR: invalid ForegroundStyle value');
            end
            update(object);
        end
        function set.BackgroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.BackgroundColor=value;
            update(object);
        end
        function set.LineWidth(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid line width');
            object.LineWidth=value;
            update(object);
        end
        function set.Visible(object,value)
            assert(ischar(value),'ERROR: invalid Visible value');
            value=lower(value);
            switch value
                case {'on','off'}
                    object.Visible=value;
                otherwise
                    error('ERROR: invalid Visible value');
            end
        end
    end
end