function object=create(object,varargin)

% probability density estimation
param=struct();
param.GridPoints=100;
param.SmoothFactor=2;
param.PadFactor=5;
param.NumberContours=5;
object.DensitySettings=param;

% optimization
object.OptimizationSettings=optimset;

% add measurements as necessary
if numel(varargin)>0
    object=add(object,varargin{:});
end

end