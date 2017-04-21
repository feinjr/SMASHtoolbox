classdef Digitizer < handle
    properties
        Name = '(unnamed digitizer)' % Digitizer name
    end
    properties (SetAccess=protected)
        Address % IP address
        VISA % VISA object
    end
    properties (Dependent=true)
        Bandwidth
        SampleRate
        NumberPoints
        NumberAverages
        Trigger
        StartTime
        Channel1 
        Channel2
        Channel3
        Channel4
    end
    properties (Dependent=true, SetAccess=protected)
        Status
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
            ID=strtrim(fscanf(object.VISA));
            fprintf('Connected to:\n\t%s\n',ID);
        end
    end
    %%
    methods (Static=true)
        varargout=ping(varargin)
        varargout=ipconfig(varargin)
    end
    %% getters 
    methods (Hidden=true)
        varagout=getSampleRate(varargin)
        varargout=getAverage(varargin)
        varargout=getPoints(varargin)
        varargout=getBandwidth(varargin) % may need to be moved
        varargout=getCalibration(varargin)
    end
    methods
        function value=get.SampleRate(object)
            value=getSampleRate(object);
        end
        function value=get.NumberAverages(object)
            value=getAverage(object);
        end
        function value=get.NumberPoints(object)
            value=getPoints(object);
        end
        function value=get.Bandwidth(object)
            value=getBandwidth(object);
        end
        function value=get.Calibration(object)
            value=getCalibration(object);
        end        
    end
    
    %% setters
    methods (Hidden=true)
        varargout=setSampleRate(varargin)
        varargout=setAverage(varargin)
        varargout=setPoints(varargin)
    end
    methods
        function set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.Name=value;
        end
        function set.SampleRate(object,value)
            setSampleRate(object,value);
        end                
        function set.NumberAverages(object,value)
            setAverage(object,value);
        end
        function set.NumberPoints(object,value)
            setPoints(object,value);
        end
    end
end