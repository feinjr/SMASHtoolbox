function varargout=view(object,varargin)

varargout=cell(1,nargout);
[varargout{:}]=view(object.Measurement,varargin);

end