classdef Digitizer < handle
    properties
        Name = '(unnamed digitizer)' % Digitizer name
        ID % Digitizer ID
    end
    properties (SetAccess=protected)
        Address % IP address
    end
    properties (SetAccess=protected, Hidden=true)
        VISA % VISA object
    end
    properties (Dependent=true)
        Acquisition       
        Trigger
        Channel
    end
    properties (Dependent=true, SetAccess=protected)
        RunState
        Calibration
    end    
    %%
    methods (Hidden=true)
        function object=Digitizer(address)
            assert(nargin ==1 ,'ERROR: no IP address specified');            
            delay=SMASH.Z.Digitizer.ping(address);
            assert(~isnan(delay),'ERROR : invalid IP address');
            object.Address=address;
            list=instrfind();
            for k=1:numel(list)
                if strcmp(list(k).RemoteHost,address)
                    object.VISA=list(k);
                    break
                end
            end
            if isempty(object.VISA)
                object.VISA=visa('AGILENT',...
                    sprintf('TCPIP0::%s',object.Address));
            end
            if strcmp(object.VISA.Status,'closed')
                fopen(object.VISA);
            end
            fwrite(object.VISA,'*IDN?');
            object.ID=strtrim(fscanf(object.VISA));
        end
        varargout=close(varargin)
        varargout=open(varargin)
        varargout=communicate(varargin)
    end
    %%
    methods (Static=true)
        varargout=localhost(varargin)
        varargout=ping(varargin)
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
            object.Name=value;
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