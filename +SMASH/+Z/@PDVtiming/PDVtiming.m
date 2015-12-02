classdef PDVtiming < handle       
    properties (SetAccess=protected)
        Measurement % Measurement labels
        Probe % Probe numbers
        Diagnostic % Diagnostic channel number
        Digitizer % Digitizer numbers
        DigitizerChannel = [1 2 3 4] % Digitizer channel numbers
        ConnectionTable % Connection table (four columns)
        SmoothDuration = 1e-9 % [seconds]
    end
    properties (SetAccess=protected)
        ProbeDelay
        DiagnosticDelay
        DigitizerDelay
        DigitizerTrigger  
    end
    properties
        WaitForUser=true % 
    end
    methods (Hidden=true)
        function object=PDVtiming(filename)
            % manage input
            if (nargin>0) && ischar(filename)
                restore(object,filename);
            end
        end
        varargout=restore(varargin);
    end
    methods (Static=true)
        varargout=showGUI(varargin);        
    end
end

% 
% % manage input
% 
% % create dialog box
% dlg=SMASH.MUI.Dialog;
% label={'Measurement' 'Probe' 'PDV' 'Dig' 'Ch'};
% widths=[20 0 0 0 0];
% h=addblock(dlg,'table',label,widths,10);
% set(h(1),'TooltipString','Measurement label');
% set(h(2),'ToolTipString','Probe ID');
% set(h(3),'TooltipString','PDV channel');
% set(h(4),'TooltipString','Digitizer number');
% set(h(5),'TooltipString','Digitizer channel');
% 
% locate(dlg,'northeast');
% 
% % dummy data
% data=cell(6,4);
% 
% 
% 
% %    function forceInteger(source,EventData)
% %        value=sscanf(EventData.EditData,'%g',1);        
% %        row=EventData.Indices(1);
% %        column=EventData.Indices(2);
% %        %source.Data{row,column}=sprintf('%.0f',value);
% %        source.Data{row,column}=round(value);
% %    end
% 
% %end