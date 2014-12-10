classdef GraphicOptions < hgsetget
    %%
    properties
        LineStyle = '-'
        LineColor = 'black'
        LineWidth = 0.5
        Marker = 'o'
        MarkerSize = 5
        MarkerStyle = 'open'
        Box = 'on'
        AspectRatio = 'auto'
        AxesColor = 'white'
        XDir = 'normal'
        YDir = 'normal'
        Title = ''
        PanelColor = get(0,'DefaultUIPanelBackgroundColor')
        ColorMap = jet(64)
        FigureColor = get(0,'DefaultFigureColor')
    end
    %% property setters
    methods (Hidden=true)
        function object=GraphicOptions(varargin)
            % handle previous objects
            if (nargin==1) && isstruct(varargin{1})
                previous=varargin{1};
                name=fieldnames(previous);
                for k=1:numel(name)
                    if isprop(object,name{k})
                        object.(name{k})=previous.(name{k});
                    end
                end
                return
            end
            % handle new objects
            assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');
            for n=1:2:nargin
                name=varargin{n};
                assert(isprop(object,name),'ERROR: invalid name');
                object.(name)=varargin{n+1};
            end
        end
    end
    methods
        function set.LineStyle(object,value)
            switch value
                case {'-','--','-.',':','none'}
                    object.LineStyle=value;
                otherwise
                    error('ERROR: invalid line style');
            end
        end
        function set.LineColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.LineColor=value;
        end
        function set.LineWidth(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid line width');
            object.LineWidth=value;
        end
        function set.Marker(object,value)
            switch value
                case {...
                        '+','o','*','.','x','s','square','d','diamond',...
                        '^','v','>','<','p','pentagram',...
                        'h','hexagram','none'}
                    object.Marker=value;
                otherwise
                    error('ERROR: invalid marker');
            end
        end
        function set.MarkerStyle(object,value)
            assert(ischar(value),'ERROR: invalid marker style');
            value=lower(value);
            switch value
                case 'open'
                    object.MarkerStyle=value;
                otherwise
                    error('ERROR: invalid marker style');
            end
        end
        function set.MarkerSize(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid marker size');
            object.MarkerSize=value;
        end
        function set.Box(object,value)
            assert(ischar(value),'ERROR: invalid box value');
            value=lower(value);
            switch value
                case {'on','off'}
                    object.Box=value;
                otherwise
                    error('ERROR: invalid Box value');
            end
        end
        function set.AspectRatio(object,value)
            assert(ischar(value),'ERROR: invalid AspectRatio value');
            value=lower(value);
            switch value
                case {'auto','equal'}
                    object.AspectRatio=value;
                otherwise
                    error('ERROR: invalid AspectRatio value');
            end
        end
        function set.AxesColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid AxesColor value');
            object.AxesColor=value;
        end
        function set.XDir(object,value)
            assert(ischar(value),'ERROR: invalid XDir value');
            value=lower(value);
            switch value
                case {'normal','reverse'}
                    object.XDir=value;
                otherwise
                    error('ERROR: invalid XDir value');
            end
        end
        function set.YDir(object,value)
            assert(ischar(value),'ERROR: invalid YDir value');
            value=lower(value);
            switch value
                case {'normal','reverse'}
                    object.YDir=value;
                otherwise
                    error('ERROR: invalid YDir value');
            end
        end
        function set.Title(object,value)
            if ischar(value)
                object.Title=value;
            elseif iscell(value) && all(cellfun(@ischar,value))
                object.Title=value;
            else
                error('ERROR: invalid Title value');
            end 
        end
        function set.PanelColor(object,value)
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid PanelColor value');
            object.PanelColor=value;
        end
        function set.ColorMap(object,value)
            result=false;
            if isnumeric(value)
                valid=(value>=0) & (value<=1);
                if (size(value,2)==3) && all(valid(:))
                    result=true;
                end
            elseif ischar(value)
                if exist(value,'file')
                    result=true;
                end
            end
            assert(result,'ERROR: invalid ColorMap value');
            object.ColorMap=value;
        end
        function set.FigureColor(object,value)
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid FigureColor value');
            object.FigureColor=value;
        end        
    end
end