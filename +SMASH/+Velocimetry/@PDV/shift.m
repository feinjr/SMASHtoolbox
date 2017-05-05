% shift Shift time axes
%
% This mehthod shifts all time information associated with a PDV object
% (measurement, preview, etc.).
%    object=shift(object,value);
%
% See also PDV, scale
%

%
% created March 27, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=shift(object,varargin)

try
    object.PrivateSTFT.Measurement=shift(...
        object.PrivateSTFT.Measurement,varargin{:});
catch
    error('ERROR: invalid shift value');
end
value=varargin{1};

% preview
if ~isempty(object.Preview)
    object.PrivatePreview=shift(object.PrivatePreview,'Grid1',value);
end

% bounds
for n=1:numel(object.PrivateBoundary)
    data=object.PrivateBoundary{n}.Data;
    data(:,1)=data(:,1)+value;
    object.PrivateBoundary{n}=define(object.PrivateBoundary{n},data);
end

% results
for n=1:numel(object.AnalysisResult)
    object.AnalysisResult{n}=shift(object.AnalysisResult{n},value);   
end

end