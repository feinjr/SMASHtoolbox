% view View XRD object graphically
%
% This method displays XRD objects as Image plots.  The default view is the
% measured data.
%     >> view(object);
%     >> view(object,'Measurement'); % same as above
% Results can be viewed *after* the analysis method has been used.
%     >> view(object,'Angle');
%
% Specifying an output returns graphic handles for lines from this method.
%     >> h=view(...);
% 
% See also XRD, analyze
%

% 
% created August 25, 2015 by Tommy Ao (Sandia National Laboratories)
%
function varargout=view(object,mode,target)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid mode');

if (nargin<3) || isempty(target)
    target=[];
end

% generate plot
% NEEDS WORK!
switch lower(mode)
    case 'measurement'
        h=view(object.Measurement,target);
    case 'angle'
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=h;
end

end