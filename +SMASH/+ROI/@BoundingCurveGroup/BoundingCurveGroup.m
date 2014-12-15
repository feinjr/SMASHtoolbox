% This class manages multiple BoundingCurve objects.  It can be created as
% an empty group:
%     >> group=BoundingCurveGroup;
% or from existing objects.
%     >> group=BoundLineCurve(bound1,bound2,...);
%
% See also ROI, BoundingCurve
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef BoundingCurveGroup < handle
    %%
    properties (SetAccess=protected)
        Children = {} % Cell array of BoundingCurve objects
    end
    %%
    methods (Hidden=true)
        function object=BoundingCurveGroup(varargin)
            if nargin>0
                add(object,varargin{:});
            end
        end
        varargout=addlistener(varargin);
        varargout=eq(varargin);
        varargout=findobj(varargin);
        %varargout=findprop(varargin);
        varargout=ge(varargin);
        varargout=getdisp(varargin);
        varargout=gt(varargin);
        varargout=le(varargin);
        varargout=lt(varargin);
        varargout=ne(varargin);
        varargout=notify(varargin);
        varargout=setdisp(varargin);
    end
    %% static methods
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=SMASH.General.GraphicOptions();
            name=fieldnames(data);
            for k=1:numel(name)
                if isprop(object,name{k})
                    object.(name{k})=data.(name{k});
                end
            end
        end
    end   
end