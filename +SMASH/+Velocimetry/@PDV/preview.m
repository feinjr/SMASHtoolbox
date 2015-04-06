% preview Generate/display preview spectrogram
%
% This method generates and displays preview spectrograms for PDV objects.
% The standard process for doing this is:
%     >> object=preview(object); % generate spectrogram
%     >> preview(object); % display spectrogram in a new figure
%     >> preview(object,target); % display spectrogram in target axes
% The spectrogram is stored as an Image sub-object in the Preview property.
%  Except for partitioning (described below), all settings for the preview
% image are derived from the object's configuration.
%
% The standard preview is a spectrograms with 1000 non-overlapping blocks.
% Alternate partitioning can also be specified.
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
        object=preview(object);
    end
    if Narg==0
        view(object.Preview);
    elseif Narg==1
        view(object.Preview,[],varargin{1});
    else
        error('ERROR: invalid preview request');
    end 
    return
end

% generate preview
if (Narg<1) || isempty(varargin{1})
    type='blocks';
    param=[1000 0];
else
    type=varargin{1};
    param=varargin{2};
end

previous.Partition=object.Measurement.Partition;
object.Measurement=partition(object.Measurement,type,param);
object.Preview=analyze(object.Measurement);
object.Preview.Name='Preview spectrogram';
object.Preview.GraphicOptions.Title='Preview spectrogram';

object.Measurement=partition(object.Measurement,previous.Partition);
varargout{1}=object;

end