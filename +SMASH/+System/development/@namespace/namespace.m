% This class creates objects for accessing functions/classes outside of the
% standard MATLAB name space.
%
% dot notation for properties and methods does not work for this class!
%
% See also System
%

%
%
%
classdef namespace
    properties (SetAccess=protected,GetAccess=protected)
        Names = {}
        Handles = {}
    end
    methods (Hidden=true)
        function object=namespace(varargin)
            % under construction
            %if nargin==0 % test mode
            %    object.Names={'dir' 'what' 'pwd'};
            %    object.Handles={@dir @what @pwd};
            %end
            if nargin==0
                varargin{1}='';
            end
            package=varargin{1};
            % determine where module is being defined
            callstack=dbstack('-completenames');
            if numel(callstack)==1
                start=pwd;
            else
                start=callstack(2).file;
                start=fileparts(start); % strip off function name
            end            
            % locate top package level
            root={};
            while numel(start)>0
                [temp,dirname]=fileparts(start);
                if dirname(1)=='+'
                    start=temp;
                    root{end+1}=dirname(2:end);
                else
                    break
                end
            end
            root=sprintf('%s.',root{:});
            package=[root package];
            if isempty(package)
                error('ERROR: no package could be found');
            elseif package(end)=='.'
                package=package(1:end-1);
            end            
            % link package files to module
            target=strrep(package,'.',[filesep '+']);
            target=[filesep '+' target];
            target=fullfile(start,target);
            file=dir(target);
            for n=1:numel(file)
                if file(n).isdir
                    continue % ignore directories
                end
                [~,function_name,ext]=fileparts(file(n).name);
                if strcmpi(ext,'.m')  || strcmpi(ext,'.p')
                    % do nothing
                else
                    continue % ignore non-MATLAB files
                end
                %name.(function_name)=str2func(sprintf('%s.%s',package,function_name));
                object.Names{n}=function_name;
                object.Handles{n}=str2func(sprintf('%s.%s',package,function_name));
            end                                    
        end
        varargout=subsref(varargin);
        varargout=disp(varargin);
    end
end