function object=create(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

data=list2structure();
list=fieldnames(data);
for n=1:2:Narg
    name=varargin{n};
    found=false;
    for m=1:numel(list)
        if strcmpi(name,list{m})
            found=true;
            break
        end
    end
    assert(found,'ERROR: invalid density setting name');
    data.(list{m})=varargin{n+1};
end

% verify settings
in=SMASH.General.structure2list(data);
data=list2structure(in{:});
object.DensitySettings=data;

end

function data=list2structure(varargin)

dummy=SMASH.MonteCarlo.Density2D(varargin{:});
data=struct();
name=properties(dummy);
for n=1:numel(name)
   value=dummy.(name{n});
   if isempty(value)
       continue
   else
       data.(name{n})=value;
   end
end

end