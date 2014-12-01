% TRANSFORM Transform object to another representation
%
% This method applies transformations to Signal objects, moving from one
% variable representation to another.  
% UNDER CONSTRUCTION!
%By default, the fast Fourier
% transform (FFT) is chosen, transforming Grid/Data arrays to power and
% phase spectra.
%    >> [frequency,power,phase]=transform(object,...);
% Optional input pairs can be specified to control FFT calculations.
%    -'WindowName' specifies the digital window function
%    -'Window' specifies the digital window directly
%    -'RemoveDC' allows DC removal prior to transformation (default is true)
%    -'NumberFrequencies' defines the number of frequencies produced by the transform.
% Valid window names include 'Hann', 'Hamming', and 'boxcar'.  Custom
% windows are specified as arrays, whose size must match the object's limit
% region.  The number of frequencies in the transform may be specified as
% one or two numbers.  If a single number is passed, it is treated as the
% minimum number of frequencies; signals are zero padded as needed to
% produce no less than this number of frequency points.  Specifying a
% second number defines the maximum number of frequencies in the spectrum;
% if the transform yields additional points, the spectrum is
% down-converted.
%
% After one FFT has been performed, subsquent calculations can be repeated
% with the same options using the 'previous' option.
%    >> [frequency,power,phase]=transform(object,'previous');
% Input handling and initial preparations are bypassed in this call, so
% these calculations should be faster than the initial transform.
%
% Additional signal transformations are under construction at this time...
%
% See also Signal
%

% created October 5, 2013 by Daniel Dolan (Sandia National Laboratories) 
function varargout=transform(object,choice,varargin)

% handle input
if (nargin<2) || isempty(choice)
    choice='FFT';
end

% call the requested transform
varargout=cell(1,nargout);
[signal,time]=limit(object);
switch choice
    case 'FFT'
        [varargout{:}]=customFFT(signal,time,varargin{:});
    otherwise
        error('ERROR: %s is not a supported transformation',choice);
end

end