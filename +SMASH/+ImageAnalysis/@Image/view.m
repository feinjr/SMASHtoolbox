% VIEW Image visualization
%
% This method provides several types of visualization for Image objects.
% By default:
%    >> view(object);
% the objected is displayed as a single image in a new figure; a graphic
% handle can be passed to render the image in a specific location.
%    >> view(object,gca); % show image in current axes
% The standard view shows the image with a colorbar and uses labels
% specified in the object.
%
% A detailed view of the full image with an adjustable subregion
% can be created as shown below.
%    >> view(object,'detail'); % create new figure
%    >> view(object,'detail',fig); % draw in exiting figure
% The detail region can be moved by clicking on the full image or by
% pressing the direction keys.  To change the size of this region, press a
% direction key while holding down the shift key.
%
% An interactive view with vertical and horizontal cross sections is also
% provided.
%    >> view(object,'explore');
% Clicking on the main image or pressing the direction keys moves cross
% section location.
%
% In all cases, graphic handles created by the method are
% returned as a structure.
%    >> h=view(...);
% 
% See also Image, slice

%
% created November 25 2013 by Daniel Dolan (Sandia National Laboratories)
%
%function varargout=view(object,varargin)
function varargout=view(object,mode,target)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if (nargin<2) || isempty(mode)
    mode='show';
end

if nargin<3
    target=[];
end

% call the appropriate method
switch lower(mode)
    case 'show'
        h=show(object,target);
    case {'explore'}
        h=explore(object,target);
    case {'detail'}
        h=detail(object,target);
    otherwise
end

% handle output
if nargout>=1
    varargout{1}=h;
end

end