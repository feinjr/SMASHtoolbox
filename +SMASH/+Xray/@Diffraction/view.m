% view View Diffraction object graphically
%
% This method displays Diffraction objects as Image and Signal plots.  
% The default view is the measured Image.
%     >> view(object);
%     >> view(object,'Measurement'); % same as above
% Results can be viewed *after* the analysis method has been used.
%     >> view(object,'AngularProfile');
% 
% See also Xray, Diffraction
%

% 
% created September 14, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao
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
    case 'angularprofile'
        [varargout{:}]=view(object.AngularProfile,varargin{:});
    otherwise
        error('ERROR: invalid view choice');
end

end