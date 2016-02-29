function object=configure(object,varargin)


end

function object=BoundaryType(object,value)
assert(ischar(value),'ERROR: invalid BoundaryType setting');
value=lower(value);
switch value
    case {'closed','projected','wrapped'}
        % valid choices
    otherwise
        error('ERROR: invalid BoundaryType setting');
end
object.BoundaryType=value;
object=reset(object);
end