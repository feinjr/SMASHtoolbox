function object=create(object,source,varargin)

% manage input
assert(nargin>1,'ERROR: insufficient input');
assert(isa(source,'SMASH.MontCarlo.Cloud'),'ERROR: invalid source');
assert(source.NumberVariables==2,'ERROR: source cloud must have two variables');

setting=struct();
setting.IsNormal=false;
setting.GridPoints=[100 100];
setting.SmoothFactor=2;
setting.PadFactor=5;
setting.ContourRatio=0.50; % relative
setting.DensityThreshold=1e-9; % relative
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{n+1};
    switch lower(name)
        case 'isnormal'
            assert(islogical(value) && isscalar(value),...
                'ERROR: invalid IsNormal value');
            setting.IsNormal=value;
        case 'gridpoints'   
            assert(isnumeric(value),'ERROR: invalid GridPoints value');
            if isscalar(value)
                value=repmat(value,[1 2]);
            end
            assert(numel(value)==2,'ERROR: invalid GridPoints value');
            assert(all(value>3) && all(value==round(value)),...
                'ERROR: invalid GridPoints value');
            setting.GridPoints=value;
        case 'smoothfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid SmoothFactor value');
            setting.SmoothFactor=vallue;
        case 'padfactor'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid PadFactor value');
            setting.PadFactor=value;
        case 'contourratio'
            assert(isnumeric(value) && isscalar(value) && (value>0) && (value<1),...
                'ERROR: invalid ContourRatio value');
            setting.ContourRatio=value;
        case 'densitythreshold'
            ssert(isnumeric(value) && isscalar(value) && (value>0) && (value<1),...
                'ERROR: invalid ContourRatio value');
            setting.DensityThreshold=value;
        otherwise
            error('ERROR: invalid setting name');
    end
end
object.Setting=setting;

% calculate density
data=source.Data;
Npoints=size(data,1);
center=mean(data,1);
object.Original.Mean=center;
data=bsxfun(@minus,data,center);

[data,D,C]=svd(data,0);
object.Final.Mean=mean(data,1);
object.Final.Std=std(data,[],1);
object.Final.Var=var(data,[],1);
object.Matrix.Reverse=D*transpose(C); % (u,v) to (x,y)
Dinv=diag(1./diag(D));
object.Matrix.Forward=C*Dinv; % (x,y) to (u,v)

width=object.Final.Std/Npoints^(1/5); % Silverman's rule
width=width*setting.SmoothFactor;
normgrid=cell(1,2);
table=nan(Npoints,1);
ku=cell(1,2);
N2=pow2(nextpow2(setting.GridPoints));

%        OriginalBoundary
%        FinalImage
%        FinalLookup



end