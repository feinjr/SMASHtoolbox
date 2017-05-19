classdef Digitizer < handle
    properties (Dependent=true)
        Name % Digitizer name
    end
    properties
        SaveLocation = 'C:\Users\Sandia\Data' % Location where data is saved *on* the digitizer
        ShareLocation = 'Data' % Shared directory name *on* the digitizer
    end
    properties (SetAccess=protected, Hidden=true)
        VISA % VISA object
        DefinedName = '' % Defined digitizer name
    end
    properties (SetAccess=protected)
        System % Digitizer system values (model, serial number, ...)
    end
    properties (Dependent=true)
        Acquisition % Acquisition settings (sample rate, points, ...)       
        Trigger % Trigger settings (source, level, ...)
        Channel % Channel settings (scale, offset, ...)
    end
    properties (Dependent=true, SetAccess=protected)
        RunState % Run state (single, run, stop)
        Calibration % Calibration info
    end    
    %%
    methods (Hidden=true)
        function object=Digitizer(address)
            assert(nargin ==1 ,'ERROR: no IP address specified');            
            delay=SMASH.System.ping(address);
            assert(~isnan(delay),'ERROR : invalid IP address');      
            list=instrfind();
            for k=1:numel(list)
                if strcmp(list(k).RemoteHost,address)
                    object.VISA=list(k);
                    break
                end
            end
            if isempty(object.VISA)
                object.VISA=visa('AGILENT',...
                    sprintf('TCPIP0::%s',address));
            end
            if strcmp(object.VISA.Status,'closed')
                fopen(object.VISA);
            end
            fwrite(object.VISA,'SYSTEM:LONGFORM ON');
            fwrite(object.VISA,'*IDN?');                       
            object.System=setupSystem(strtrim(fscanf(object.VISA)),address);                        
        end
        varargout=close(varargin)
        varargout=open(varargin)
        varargout=communicate(varargin)
    end
    %%
    methods (Static=true)      
        varargout=reset(varargin)
        varargout=scan(varargin)
    end
    methods (Static=true, Hidden=true)
        varargout=ipconfig(varargin)
    end
    %% getters 
    methods (Hidden=true)
        varargout=getAcquisition(varargin)       
        varargout=getTrigger(varargin)
        varargout=getChannel(varargin)
        varargout=getState(varargin)
        varargout=getCalibration(varargin)       
    end
    methods
        function value=get.Name(object)
            value=object.DefinedName;
            if isempty(value)
                value=sprintf('%s-%s',...
                    object.System.ModelNumber,object.System.SerialNumber);
            end
        end
        function value=get.Acquisition(object)
            value=getAcquisition(object);
        end       
        function value=get.Trigger(object)
            value=getTrigger(object);
        end      
        function value=get.Channel(object)
            value=getChannel(object);
        end
        function value=get.RunState(object)
            value=getState(object);
        end
        function value=get.Calibration(object)
            value=getCalibration(object);
        end        
    end
    
    %% setters
    methods (Hidden=true)
        varargout=setAcquisition(varargin)
        varargout=setTrigger(varargin)
        varargout=setChannel(varargin)
    end
    methods
        function set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.DefinedName=strtrim(value);            
        end
        function set.SaveLocation(object,value)
            assert(ischar(value),'ERROR: invalid save location');
            index=(value=='/') | (value=='\');
            value(index)=filesep;            
            object.SaveLocation=strtrim(value);
        end
         function set.ShareLocation(object,value)
            assert(ischar(value),'ERROR: invalid share location');
            index=(value=='/') | (value=='\');
            value(index)=filesep;
            object.ShareLocation=strtrim(value);
        end
        function set.Acquisition(object,value)
            setAcquisition(object,value);
        end
        function set.Trigger(object,value)
            setTrigger(object,value);
        end
        function set.Channel(object,value)
            setChannel(object,value);
        end
    end
end