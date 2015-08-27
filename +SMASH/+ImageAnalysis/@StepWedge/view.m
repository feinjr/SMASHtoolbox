% view Step wedge visualization
%
% This method visually displays step wedge information.  The default
% visualization is the measured image.
%     >> view(object);
%     >> view(object,'Measurement');
%     >> view(object,'Measurement',option);
%  The default option is 'display'; 'detail' and 'explore' are also valid
%  options.
%
% UNDER CONSTRUCTION...
%
% See also StepWedge, clean, crop, rotate, ImageAnalysis.Image.view
%

%
% created August 26, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,choice,varargin)


% manage input
if (nargin<2) || isempty(choice)
    choice='measurement';
end
assert(ischar(choice),'ERROR: invalid view choice');

% perform requested view
varargout=cell(1,nargout);
switch lower(choice)
    case 'measurement'
        [varargout{:}]=view(object.Measurement,varargin{:});
    otherwise
        error('ERROR: invalid view choice');
end

end