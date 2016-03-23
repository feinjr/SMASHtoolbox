% view Display noise signal or spectrum
%
% This method graphically displays a NoiseSignal object.  The default
% display is the noise signal stored in the Measurement property.
%    view(object);
%    view(object,'measurement');
% Changing the second input displays the frequency spectrum.
%    view(object,'spectrum');
%
% Graphic handles are returned as outputs (if present) in all cases.
%    hl=view(...);
%
% See also NoiseSignal
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid view mode');

% generate plot
switch lower(mode)
    case 'measurement'
        hl=view(object.Measurement,varargin{:});      
    case 'spectrum'      
        [f,P]=fft(object.Measurement);                
        temp=SMASH.SignalAnalysis.Signal(f,P);
        temp.GridLabel='Frequency';
        temp.DataLabel='Power';
        hl=view(temp,varargin);        
    case 'autocorrelation'
        
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=hl;
end

end