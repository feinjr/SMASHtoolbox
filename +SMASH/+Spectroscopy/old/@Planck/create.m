function object=create(object,varargin)

% handle input (UNDER CONSTRUCTION)
Narg=numel(varargin);
assert(Narg>1);
object.Grid=varargin{1};
if Narg==2
    object.Data=varargin{2};
elseif Narg==3
    object.Temperature=varargin{2};    
        object.Emissivity=varargin{3};
    object.Data=plancksLaw(object.Grid,...
        object.Temperature,object.Emissivity);
else
    error('ERROR: too many inputs');
end
object.Name='Planck object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Title='Planck object';
object.DataLabel='Spectral Radiance (W·sr^{-1}·m^{-2}·nm^{-1}) ';
object.GridLabel='Wavelength (nm) ';
object.GridType='Wavelength';

end