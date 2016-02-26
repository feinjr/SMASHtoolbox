% 2D probability density
%
% (x,y) -> (u,v)
%
% object=Density2D(source,...);
%   source must be a Cloud object


%
%
%
classdef Density2D
    %%
    properties (SetAccess=protected)
        Original
        Final
        Matrix        
        Setting
    end
    %%
    methods (Hidden=true)
        function object=Density2D(varargin)
            if (nargin==1) && strcmpi(varargin{1},'-empty')
                return
            end
            object=create(object,varargin{:});
        end
    end
    %%
    methods (Static=true,Hidden=true)
        varargout=restore(varargin);
    end
end