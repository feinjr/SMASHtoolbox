function object=create(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

% default settings
data=list2structure();
data.GridPoints=500;
data.SmoothFactor=4;
%data.ContourFraction=exp(-2^2/2);
data.ContourFraction=[0.25 0.50 0.75];

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

% graphic options
option=struct();
option.MeasurementColor='k';
option.MeasurementStyle='--';

option.ModelColor='k';
option.ModelStyle='-';
option.ModelWidth=1;

object.GraphicOptions=option;

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