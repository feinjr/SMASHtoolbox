function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid view mode');

% generate view
varargout=cell(1,nargout);

switch lower(mode)
    case 'measurement'
       [varargout{:}]=view(object.Measurement,varargin{:}); 
end  


end