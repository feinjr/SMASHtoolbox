function object=create(object,varargin)

% optimization
object.OptimizationSettings=optimset;

% graphical display
param=struct();
param.XLabel='X';
param.YLabel='Y';
object.DisplaySettings=param;

object.ModelSettings = struct('Function',[],'Parameters',[],'Bounds',[],...
            'Slack',[],'SlackReference',[],'Curve',[]); 

% add measurements as necessary
if numel(varargin)>0
    object=add(object,varargin{:});
end

end