function object=create(object,varargin)

% handle input (UNDER CONSTRUCTION)

object.Grid=varargin{1};
if nargin<3
    object.Data=varargin{2};
else
    object.Temperature=varargin{2};
    object.Emissivity=varargin{3};
    object.Data=plancksLaw(object.Grid,...
        object.Temperature,object.Emissivity);
end
object.Name='Planck object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Title='Planck object';
object.DataLabel='Spectral Radiance (W·sr^{-1}·m^{-2}·nm^{-1}) ';
object.GridLabel='Wavelength (nm) ';
object.GridType='Wavelength';

end