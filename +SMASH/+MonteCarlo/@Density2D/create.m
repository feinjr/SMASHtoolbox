function object=create(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

%list={'GridPoints' 'SmoothFactor' 'PadFactor' ...
%    'MinDensityFraction' 'ModeFraction' 'ContourFraction'};
list=properties(object);
M=numel(list);

for n=1:2:Narg
    name=varargin{n};
    match=false;
    for m=1:M
        if strcmpi(name,list{m}) && ~isempty(object.(name))
            name=list{m};
            match=true;
        end
    end
    assert(match,'ERROR: invalid parameter name');
    object.(name)=varargin{n+1};    
end

end