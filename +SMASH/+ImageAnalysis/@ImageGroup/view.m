% VIEW View ImageGroup Data
%
% This is a temporary method that opens the designated individual Image from the
% provided ImageGroup in a separate window.
%
% view(object,ImageNumber);
% 
% See also ImageGroup
%

%
% created January 12, 2016 by Sean Grant (Sandia National Laboratories/UT)
%
function varargout=view(object,varargin)

% verify uniform grid
% object=makeGridUniform(object);

% assert(1<=varargin{1}&&varargin{1}<=object.NumberImages,'invalid Image number selection')

if(nargin<2)
    temp=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,1));
else
    assert(1<=varargin{1}&&varargin{1}<=object.NumberImages,'invalid Image number selection')
    temp=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,varargin{1}));
end

varargout=view(temp);

end
