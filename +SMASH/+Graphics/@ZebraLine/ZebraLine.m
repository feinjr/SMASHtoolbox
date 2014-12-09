% Basic zebra line class
classdef ZebraLine
    %%
    properties
        XData
        YData
        ForegroundColor = 'black'
        BackgroundColor = 'white'  
        LineWidth = 0.5
    end
    properties
        Group
        Status = 'alive'
    end
    %% 
    methods (Hidden=true)
        function object=ZebraLine(x,y)
            object.XData=x;
            object.YData=y;
            object.Group=hggroup('Visible','off');
            line('Parent',object.Group,'LineStyle','-','Tag','Background');
            line('Parent',object.Group,'LineStyle','--','Tag','Foreground');
            update(object);
        end
    end
    %%
    methods
        function object=set.ForegroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.ForegroundColor=value;
        end
        function object=set.BackgroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.BackgroundColor=value;
        end
        function object=set.LineWidth(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid line width');
            object.LineWidth=value;
        end
    end
end