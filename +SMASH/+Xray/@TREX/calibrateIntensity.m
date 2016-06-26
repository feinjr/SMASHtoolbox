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