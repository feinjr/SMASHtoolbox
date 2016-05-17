function object=create(object,varargin)

warning('SMASH:obsolete',...
    'This class is obsolete and will be removed from the toolbox. \n Use the StepWedge class instead.');

object=create@SMASH.ImageAnalysis.Image(object,varargin{:});
object.Name='Wedge object';
object.GraphicOptions.Title='Wedge object';

end