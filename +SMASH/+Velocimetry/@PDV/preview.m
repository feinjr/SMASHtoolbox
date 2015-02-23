% preview Generate/display preview spectrogram
%
% This method generates and displays preview spectrograms for PDV objects.
% The standard process for doing this is:
%     >> object=preview(object); % generate spectrogram
%     >> preview(object); % display spectrogram in a new figure
%     >> preview(object,target); % display spectrogram in target axes
% The spectrogram is stored as an Image sub-object in the Preview property.
%
% The standard preview is a spectrograms with 1000 non-overlapping blocks.
% Alternate partitioning can also be specified.
%     >> object=preview(object,{'duration' [duration advance]});
%     >> object=preview(object,{'points' [points skip]});
%     >> object=preview(object,{'blocks' [number overlap]});
% See the STFT class for more information about partition types and and
% settings.  
%
% Previews are usually power spectrograms, but the real and imaginary
% components of the Fourier transform can be preserved.
%     >> object=preview(object,partition,'complex'); % complex spectra
%     >> object=preview(object,partition,'power');   % power spectra (default)
% Power spectra contain less information that power spectra but are easier
% to visualize.
%
% WARNIGN: previews are not automatically regenerated when an object is
% changed!  The following is a conceptual workflow.
%     >> object=preview(object); % original preview
%     >> object=modify(object,...); % change object settings
%     >> object=preview(object); % update preview
%
% See also PDV, configure, SignalAnalysis.STFT.partition
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
Narg=numel(varargin);
if (Narg<1) || isempty(varargin{1})
    type='blocks';
    param=[1000 0];
else
    type=varargin{1}{1};
    param=varargin{1}{2};
end

if (Narg<2) || isempty(varargin{2})
    SpectrumType='power';
else
    SpectrumType=varargin{2};
end
previous.SpectrumType=object.Measurement.FFToptions.SpectrumType;

previous.Partition=object.Measurement.Partition;
object.Measurement=partition(object.Measurement,type,param);
object.Measurement.FFToptions.SpectrumType=SpectrumType;
object.Preview=analyze(object.Measurement);

object.Measurement=partition(object.Measurement,previous.Partition);
object.Measurement.FFToptions.SpectrumType=previous.SpectrumType;
varargout{1}=object;

end