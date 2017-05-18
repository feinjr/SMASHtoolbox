% This class provides tools for accessing package functions and classes.
% To illustrate why the tools are useful, consider the following hierarchy.
%    +MainPackage/
%       MainFuncA.m
%       MainFuncB.m
%       +SubPackage1/
%          SubFuncA.m
%          SubFuncB.m
%       +SubPackage2/
%          SubFuncC.m
%          SubFuncD.m
%
% Package functions may be called explicitly:
%    MainPackage.MainFuncA();
% or by importing the package into the current workspace.
%    import MainPackage.SubPackage1.*
%    SubFuncA();
% Both approaches assume a fixed package hierarchy, but this assumption can
% be problematic.  For example, the author of "SubFuncA" may have known
% that the function would be in a package, but not in a subpackage.
% Explicit naming may require a *lot* of manual revisions when packages are
% moved around or renamed.  Package imports reduce (but do not eliminate)
% this problem with potential side effects: name clashes with existing
% functions can lead to unexpected results.
%


%
% created May 14, 2017 by Daniel Dolan
%
classdef (Abstract) packtools
    %%
    methods (Hidden=true)
        function object=packtools(varargin)           
        end
    end
    %% 
    methods (Static=true)
        varargout=call(varargin)
        varargout=namespace(varargin)
        varargout=import(varargin)
    end
end