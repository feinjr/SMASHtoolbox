function object=create(object,varargin)

object.GraphicOptions=SMASH.General.GraphicOptions('Marker','+');

object.DensityOptions.GridPoints=[100 100];
object.DensityOptions.SmoothFactor=2;
object.DensityOptions.PadFactor=5;
object.DensityOptions.MinDensityFactor=1e-9;
object.DensityOptions.ContourFraction=exp(-2^2/2);

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid density option name');
    value=varargin{n+1};
    switch lower(name)
        case 'gridpoints'
            assert(isnumeric(value) && all(value==round(value)),...
                'ERROR: invalid grid points value');
            if isscalar(value)
                value=repmat(value,[1 2]);
            else
                assert(numel(value)==2,'ERROR: invalid grid points value');
                value=reshape(value,[1 2]);
            end
            object.DensityOptions.GridPoints=value;
        case 'smoothfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid smooth factor value');
            object.DensityOptions.SmoothFactor=value;
        case 'padfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid pad factor value');
            object.DensityOptions.PadFactor=value;
        case 'mindensityfactor'
            assert(isnumeric(value) && isscalar(value) && ...
                (value>0) && (value<1),...
                'ERROR: invalid minimum density factor value');
            object.DensityOptions.MinDensityFactor=value;
        case 'contourfraction'
             assert(isnumeric(value) && isscalar(value) && ...
                (value>0) && (value<1),...
                'ERROR: invalid contour fraction');
            object.DensityOptions.ContourFraction=value;            
        otherwise
            error('ERROR: invalid density option name')
    end
end

end