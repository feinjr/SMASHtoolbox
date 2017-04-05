% scale Scale time axes
%
% This method scales all time and frequency information associated with a
% PDV object (measurement, preview, etc.).
%    object=scale(object,value);
% Time data are multiplied by the input "value", while frequency data (and
% the Wavelength property) are divided by this value.
%
% See also PDV, shift
%

%
% created March 27, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=scale(object,varargin)

try
    object.PrivateSTFT.Measurement=scale(...
        object.PrivateSTFT.Measurement,varargin{:});
catch
    error('ERROR: invalid scale value');
end
value=varargin{1};

% preview
if ~isempty(object.PrivatePreview)
    object.PrivatePreview=scale(object.PrivatePreview,'Grid1',value);
    frequency=object.PrivatePreview.Grid2;
    frequency=frequency/value;
    object.PrivatePreview=reset(object.PrivatePreview,[],frequency,[]);
end

% bounds
for n=1:numel(object.PrivateBoundary)
    data=object.PrivateBoundary{n}.Data;
    data(:,1)=data(:,1)*value;
    data(:,2:3)=data(:,2:3)/value;
    object.PrivateBoundary{n}=define(object.PrivateBoundary{n},data);
    object.PrivateBoundary{n}.DefaultWidth=object.PrivateBoundary{n}.DefaultWidth/value;
end

% results
for n=1:numel(object.AnalysisResult)
    object.AnalysisResult{n}=scale(object.AnalysisResult{n},value);
    data=object.AnalysisResult{n}.Data;
    data(:,[1 3])=data(:,[1 3])/value;
    object.AnalysisResult{n}=reset(object.AnalysisResult{n},[],data);
end

% wavelength
object.Wavelength=object.Wavelength*value;

end