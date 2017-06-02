% This class communicates with Agilent/Keysight digitizers via a TCP/IP
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
% See also Z
%

%
% created May 23, 2017 by Daniel Dolan (Sandia National Laboratories)
%
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
        function object=Digitizer(address,name,recursive)
            % manage input
            assert(nargin > 0 ,'ERROR: no address(es) specified');
            if ischar(address)
                address={address};
            end
            assert(iscellstr(address),'ERROR: invalid address(es)');            
            address=SMASH.Z.Digitizer.scan(address);
            assert(~isempty(address),'ERROR: no valid address found');            
            if (nargin < 2) || isempty(name)
                name=cell(size(address));
                for n=1:numel(address)
                    name{n}=sprintf('Digitizer%d',n);
                end
            elseif ischar(name)
                name={name};
            else
                assert(iscellstr(name),'ERROR: invalid name input');
            end
            assert(numel(name) == numel(address),...
                'ERROR: incompatible address/name inputs');
            if (nargin < 3) || isempty(recursive)
                recursive=false;
            elseif strcmpi(recursive,'recursive')
                recursive=true;
            end
            % deal with multiple addresses
            if numel(address) > 1 
                SMASH.Z.Digitizer.reset();
                for n=1:numel(address)
                    object(n)=SMASH.Z.Digitizer(address{n},name{n},...
                        'recursive'); %#ok<AGROW>
                end
                return
            end
            % deal with a single address
            if ~recursive
                SMASH.Z.Digitizer.reset();
            end
            object.VISA=visa('AGILENT',...
                sprintf('TCPIP::%s',address{1}));
            object.VISA.Timeout=1;
            fopen(object.VISA); % what if this fails?
            fwrite(object.VISA,'SYSTEM:LONGFORM ON');
            fwrite(object.VISA,'*IDN?');
            temp=strtrim(fscanf(object.VISA));
            object.System=setupSystem(temp,address{1});
            object.Name=name{1};
                                                                                  
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