% This class communicates with digitizers via a TCP/IP
% (Ethernet) connection.  Digitizer objects are created from a specific
% address, an address range, or a cell array of addresses.
%    dig=Digitizer('192.168.0.100'); % specific address
%    dig=Digitizer('192.168.0.100-150'); % address range
%    dig=Digitizer({'192.168.0.100' '192.168.0.105'}); % address list
% The first example returns a scalar Digitizer object, while the third
% example returns a 2x1 Digitizer object array.  The output size in the
% second example depends on the number of valid IP addresses found in the
% specified range.
%
% See also Instrument
%

%
% created May 23, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Digitizer < handle
    properties (Dependent=true)
        Name % Digitizer name
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
    properties
        RemoteDirectory % Location and share ID where data is saved *on* the digitizer
    end
    %%
    methods (Hidden=true)
        function object=Digitizer(varargin)
            if nargin == 0
                return % return empty object
            elseif (nargin == 1) && isstruct(varargin{1})
                object=importDigitizer(varargin{1});
            else                
                object=createDigitizer(object,varargin{:});
            end
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
        function set.RemoteDirectory(object,value)
            assert(isstruct(value),'ERROR: invalid remote directory setting');
            name=fieldnames(value);
            while numel(name) > 0
                switch name{1}
                    case 'Location'
                        assert(ischar(value.Location),'ERROR: invalid location');
                        index=(value.Location=='/') | (value.Location=='\');
                        value.Location(index)=filesep;
                        value.Location=strtrim(value.Location);
                        name=name(2:end);
                    case 'ShareName'
                        assert(ischar(value.ShareName),'ERROR: invalid shared name');
                        index=(value.ShareName=='/') | (value.ShareName=='\');
                        value.ShareName(index)=filesep;
                        value.ShareName=strtrim(value.ShareName);
                        name=name(2:end);
                    otherwise
                        error('ERROR: invalid remote directory setting');
                end                
            end
            object.RemoteDirectory=value;
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