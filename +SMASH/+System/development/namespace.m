% UNDER CONSTRUCTION

classdef namespace< dynamicprops
   properties
       
   end
   %%
   methods (Hidden=true)
       varargout=addlistener(varargin);
       %varargout=addprop(varargin);
       varargout=delete(varargin);
       varargout=eq(varargin);
       varargout=findobj(varargin);
       varargout=findprop(varargin);
       varargout=ge(varargin);
       varargout=gt(varargin);
       %varargout=isvalid(varargin);
       varargout=le(varargin);
       varargout=lt(varargin);
       varargout=ne(varargin);
       varargout=notify(varargin);
   end
   %%
   methods (Hidden=true)
       function object=namespace()
           % handle input
           target=pwd;
           list=what(target);
           for k=1:numel(list.m)
               [~,name,~]=fileparts(list.m{k});
               [~]=addprop(object,name);
               object.(name)=str2func(name);
           end
       end
       function display(object)
           
       end
   end
end