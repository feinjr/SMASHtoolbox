% GATHER Combine objects into a ImageGroup
%
% UNDER CONSTRUCTION
% 
% This method combines ImageGroup (and Image) objects into a new ImageGroup
% object with a common Grid.
%    >> new=gather(object1,object2,...)
%
% See also ImageGroup, split
%

%
% created January 7, 2015 by Sean Grant (Sandia National Laboratories/UT)
%
function object=gather(varargin)

temp={};
label={};
for n=1:nargin
    assert(isa(varargin{n},'SMASH.ImageAnalysis.Image'),...
        'ERROR: non-gatherable object detected')
    source=varargin{n};
    for m=1:size(source.Data,3)
        temp{end+1}=SMASH.ImageAnalysis.Image(...
            source.Grid1,source.Grid2,source.Data(:,:,m)); %#ok<AGROW>                
        switch class(source)
            case 'SMASH.ImageAnalysis.Image'
                label{end+1}=source.Name; %#ok<AGROW>
            case 'SMASH.ImageAnalysis.ImageGroup'
                label{end+1}=source.Legend{m}; %#ok<AGROW>
        end
    end
end

N=numel(temp);
[temp{:}]=register(temp{:});    % Is the Image/register really what we want here? What's the goal? - Consistent grids.
dataSize = size(temp{1}.Data);

Data=nan(dataSize(1),dataSize(2),N);
for n=1:N
    Data(:,:,n)=temp{n}.Data;
end
object=SMASH.SignalAnalysis.SignalGroup(temp{1}.Grid1,temp{1}.Grid2,Data);
object.Source='Image merge';
object.Grid1Label=varargin{1}.Grid1Label;
object.Grid2Label=varargin{1}.Grid2Label;
object.DataLabel=varargin{1}.DataLabel;
object.NumberImages=size(object.Data,3);
object.Legend=label;

end