function varargout=setDataDirectory(varargin)

% manage input
assert(nargin>=1,'ERROR: insufficient input');
name=varargin{1};
assert(ischar(name),'ERROR: invalid name');

% 
if (nargin<2)
    data=getappdata(0,'DataDirectory');
    try
        location=data.(name);
    catch
        fprintf('Location "%s" has not been set\n',name);
        location='';
    end
    if nargout>0
        varargout{1}=location;
    end
    return
end

location=varargin{2};
assert(exist(location,'dir')==7,'ERROR: invalid directory location');

data=getappdata(0,'DataDirectory');
data.(name)=location;
setappdata(0,'DataDirectory',data);

% manage output


end