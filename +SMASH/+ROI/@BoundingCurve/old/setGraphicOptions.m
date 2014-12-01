function setGraphicOptions(object,varargin)

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value');
for k=1:2:Narg
    name=varargin{k};
    assert(isfield(object.GraphicOptions,name),...
        'ERROR: %s is an invalid option',name);
    value=varargin{k+1};
    object.GraphicOptions.(name)=value;
end

end