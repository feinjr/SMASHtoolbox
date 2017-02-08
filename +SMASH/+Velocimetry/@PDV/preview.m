% preview Generate/display preview spectrogram
%
% This method generates and displays preview spectrograms for PDV objects.
% The standard process for doing this is:
%     >> object=preview(object); % generate spectrogram
%     >> preview(object); % display spectrogram in a new figure
% The spectrogram is stored as an Image sub-object in the Preview property.
%  Except for partitioning (described below), all settings for the preview
% image are derived from the object's configuration.
%
% The standard preview is a spectrograms with 1000 non-overlapping blocks.
% Alternate partitioning can be specified as shown below.
%     >> object=preview(object,'duration',[duration advance]);
%     >> object=preview(object,'points',[points skip]);
%     >> object=preview(object,'blocks',[number overlap]);
% See the STFT class for more information about partition types and
% settings.
%
% WARNING: previews are not automatically regenerated when an object is
% changed!  The following is a conceptual workflow.
%     >> object=preview(object); % original preview
%     >> object=configure(object,...); % change object settings
%     >> object=preview(object); % update preview
%
% See also PDV, configure, view, SignalAnalysis.STFT.partition
%

%
% created February 18, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=preview(object,varargin)

% display preview
Narg=numel(varargin);
if nargout==0
    if isempty(object.Preview)
        fprintf('Generating preview\n');
        object=preview(object,varargin{:});
    end   
    view(object,'Preview');
    return
end

% generate preview
if (Narg<1) || isempty(varargin{1})
    type='blocks';
    param=[1000 0];
else
    assert(Narg>=2,'ERROR: insufficient input');
    type=varargin{1};
    param=varargin{2};
end

previous.Partition=object.STFT.Partition;
object.STFT=partition(object.STFT,type,param);

object.Preview=analyze(object.STFT);
object.Preview.Name='Preview spectrogram';
object.Preview.GraphicOptions.Title='Preview spectrogram';

object.STFT=partition(object.STFT,previous.Partition);

% manage output
varargout{1}=object;

end