function object = calibrateIntensity(object,varargin)


if isempty(object.Wedge)
    if ~isempty(varargin)
        object.Wedge = SMASH.ImageAnalysis.StepWedge(varargin{1},'film');
    elseif isempty(varargin)
        temp=SMASH.ImageAnalysis.Image();
        object.Wedge=SMASH.ImageAnalysis.StepWedge(temp);
    end
    
end

object.Wedge=analyze(object.Wedge,'full');
object.Linearized = apply(object.Wedge,object.Measurement);

object.Linearized.GraphicOptions.YDir = 'Normal';
object.Linearized.GraphicOptions.AspectRatio = 'equal';
object.Linearized.GraphicOptions.LineColor = 'Magenta';
object.Linearized.GraphicOptions.Title = 'Linearized MLM Image';