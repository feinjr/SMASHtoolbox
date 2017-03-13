% crop Crop data to a region of interest
%
% This method crop PDV data to a time range of interest.
%    object=crop(object,[tmin tmax]);
%    object=crop(object); % interative cropping
% By default, interactive cropping displays the measured signal for
% zooming/panning.  Interactive cropping can also be performed using the
% preview image.
%    object=crop(object,'preview'); % interactive cropping

function object=crop(object,varargin)

% manage input
if (nargin==1) || isnumeric(varargin{1})
    try
        object.STFT.Measurement=crop(object.STFT.Measurement,varargin{:});
        t=object.STFT.Measurement.Grid;
        object.Preview=crop(object.Preview,[min(t) max(t)],[]);
    catch
        return
    end
elseif strcmpi(varargin{1},'preview')
    if isempty(object.Preview)
        object=preview(object);
    end
    try
        object.Preview=crop(object.Preview);
    catch
        return
    end
    t=object.Preview.Grid1;
    object.STFT.Measurement=crop(object.STFT.Measurement,[min(t) max(t)]);
else
    error('ERROR: invalid input');
end



end