% preview Generate/display previews
%
% This method generates and displays preview images for STFT objects.
% These images are low to moderate resolution power spectra used in
% visualization and region of interest selection.  They are generated by
% the analyze method using the current FFT settings.
%
% To generate a preview, type:
%    >> object=preview(object,choice,value);
% The inputs "choice" and "value" control the FFT window size as described
% in the partition method.  If omitted, the preview is calculated over 1000
% non-overlapping blocks.
%
% To display an exisiting preview, call this method without an output
% argument.
%    >> object=preview(object);
% By default, previews are displayed in a new figure.  Passing a target
% handle:
%    >> preview(object,target);
% causes the preview to be displayed in an existing axes.
%
% To replace an existing preview:
%    >> object=preview(object,new);
% where the input "new" is an object from the ImageAnalysis.Image class.
%
% See also STFT, analyze, partition, ImageAnalysis.Image
%

%
% created November 11, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=preview(object,varargin)

Narg=numel(varargin);
% display mode
if nargout==0
    if Narg==0
        target=[];
    else
        target=varargin{1};
        assert(ishandle(target),'ERROR: invalid target handle');
    end
    assert(~isempty(object.Preview),'ERROR: no existing preview');
    view(object.Preview,'show',target);
    return
end

% replace mode
if (Narg==1) && isa(varargin{1},'SMASH.ImageAnalysis.Image')
    object.Preview=varargin{1};
    return
end

% generate mode
if Narg==0
    choice='points';
    value(1)=object.Partition.Points;
    value(2)=object.Partition.Skip;
elseif Narg==2
    choice=varargin{1};
    value=varargin{2};
else
    error('ERROR: invalid input');
end

PreviousPartition=object.Partition;
object=partition(object,choice,value);
result=analyze(object,[],'preview');
object.Partition=PreviousPartition;

object.Preview=result;

if nargout>0
    varargout{1}=object;
end

end