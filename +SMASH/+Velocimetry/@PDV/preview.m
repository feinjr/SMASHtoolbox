% preview Generate/display preview spectrogram
%
% This method generats and displays preview spectrograms for PDV objects.
% The standard process for doing this is:
%     >> object=preview(object); % generate spectrogram
%     >> preview(object); % display spectrogram in a new figure
%     >> preview(object,target); % display spectrogram in target axes
% The spectrogram is stored as an Image sub-object in the Preview property.
%  This preview is *not* automatically regenerated when the object is
%  modified.
%
% By default, spectrograms are generated using 1000 non-overlapping blocks.
%  Alternate partitioning can also be specified.
%     >> object=preview(object,{'duration' [duration advance]});
%     >> object=preview(object,{'points' [points skip]});
%     >> object=preview(object,{'blocks' [number overlap]});
% See the "partition" method of the STFT class for more information.
%
% All FFT options (Window, NumberFrequencies, etc.) for the preview
% are taken from the STFT sub-object stored in the Measurement property.
% Changes to the sub-object are used during the next preview generation.
%     >> object.Measurement.FFToptions.NumberFrequencies=2000; % generate at least 2000 frequency points
%     >> object=preview(object,...); % update preview
% See that FFToptions class for more information.
%
% See also PDV, SignalAnalysis.STFT, General.FFToptions
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=preview(object,varargin)

% display preview
if nargout==0
    if isempty(object.Preview)
        fprintf('Generating preview\n');
        object=preview(object);
    end
    if nargin==1
        view(object.Preview);
    else
        view(object.Preview,varargin{:});
    end 
    return
end

% generate preview
if (nargin<2) || isempty(varargin{1})
    [x,~]=limit(object.Measurement);
    points=ceil(numel(x)/1000);
    type='points';
    param=points;
else
    type=varargin{1}{1};
    param=varargin{1}{2};
end

previous=object.Measurement.Partition;
object.Measurement=partition(object.Measurement,type,param);
object.Preview=analyze(object.Measurement);
object.Measurement=partition(object.Measurement,previous);

varargout{1}=object;

end