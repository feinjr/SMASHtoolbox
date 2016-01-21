% CROP Interactive cropping tool for Diffraction objects
%
% Usage:
%   >> object=crop(object,bound1,bound2); % directly input boundaries of 
%                                           crop region
%   >> object=crop(object,'manual'); % interactively select crop region
%
% See also Xray, Diffraction
%

%
% created August 27, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 21, 2016 by Tommy Ao

function object=crop(object,varargin)

% manage input
if numel(varargin)==0
    varargin{1}='manual';
end

object.Measurement=crop(object.Measurement,varargin{:});

end