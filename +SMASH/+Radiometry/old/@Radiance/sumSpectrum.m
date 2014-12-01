% SUMSPECTRUM Integrate spectrum of Radiance objects
%
% This method integrates the Data values of a Radiance object along the 
% spectral (wavelength) coordinate.
%    >> object=sumSpectrum(object);
% The "new" object is a Radiance object with a wavelength [1x1] scalar, 
% a time (1xN) row array, and a data (1xN) row array.
%
% See also Radiation, Radiance@
%

% created March 27, 2014 by Tommy Ao(Sandia National Laboratories)
%
function object=sumSpectrum(object)

% integrate with respect to wavelength
[x,~,z]=limit(object);
object.Data=trapz(x,z,1);
object.Wavelength=1;
object.Emmisivity=1;
object.NumberWavelengths=numel(object.Wavelength);
object.WavelengthLabel='All';
object.DataLabel='Radiance (W·sr^{-1}·m^{-2})';
object.Source='Radiance operation';

end
