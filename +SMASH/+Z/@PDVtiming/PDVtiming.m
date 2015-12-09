classdef PDVtiming < handle       
    properties (SetAccess=protected)
        Experiment % Experiment label
        Measurement % Measurement labels
        Probe % Probe numbers
        Diagnostic = 1:8 % Diagnostic channel number
        Digitizer = [1 2] % Digitizer numbers
        DigitizerChannel = [1 2 3 4] % Digitizer channel numbers
        ConnectionTable % Connection table (four columns)
        DigitizerScaling = 1e9 % Digitizer time scaling factor (conversion to nanoseconds)
        SmoothDuration = 1 % Derivative smoothing duration [nanoseconds]
        OBRwidth = 2 ; % OBR analysis width [nanoseconds]        
    end
    properties (SetAccess=protected)
        ProbeDelay % Probe delays
        DiagnosticDelay % Diagnostic delays
        DigitizerDelay % Digititizer output trigger delays
        DigitizerTrigger % Digitizer trigger times
    end    
    properties (Access=protected,Hidden=true)
        DialogHandle
    end
    methods (Hidden=true)
        function object=PDVtiming(name,choice)
            % manage input
            if (nargin<1) || isempty(name)
                name='Z????';
            end
            assert(ischar(name),'ERROR: invalid experiment name');
            object.Experiment=name;
            if (nargin<2) || isempy(choice)
                choice='';
            end
            assert(ischar(choice),'ERROR: invalid input');
            % process choice
            switch lower(choice)
                case 'silent'
                    % do nothing
                otherwise
                    message{1}='This clas is meant for devleopers';
                    message{2}='(message under construction)x';
                    warning('SMASH:PDVtiming','%s\n',message{:});
            end
        end
        varargout=restore(varargin);
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