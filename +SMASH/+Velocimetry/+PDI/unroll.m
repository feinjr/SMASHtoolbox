% unroll Robust displacement analysis of PDI measurements
%
% This function performs a robust analysis of Photonic Displacement
% Interferometer (PDI) measurements.  Unlike quadrature analysis, this
% approach does not require signal linearity or ellipse characterization.
% Position changes are incremented by 1/3 of a fringe each time the minimum
% signal changes.  The order of these changes--e.g., D1 -> D2 versus D2 ->
% D1---determines directionality.  The characterisitic uncertainty of this
% analysis is half of a fringe.
%
% Standard use of this function requires three data files.
%    position=unrollPDI(file1,file2,file3);
%    position=unrollPDI(file1,file2,file3,format); % explicit format specification
% The three files should use the same file format.  Format specification
% can be omitted for unambiguous file extensions.
%
% Measurements bundled into a single text file can also be used.
%    position=unrollPDI(file)
%
% See also FileAccess.SupportedFormats
%

%
% created November 7, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function position=unroll(varargin)

% manage input
assert(nargin > 0,'ERROR: insufficient input');
if nargin==1
    varargin{2}='';
elseif nargin==3
    varargin{4}='';
end
Narg=numel(varargin);

if Narg==2
    object=SMASH.SignalAnalysis.SignalGroup(varargin{:});
    t=object.Grid;
    table=object.Data;    
elseif Narg==4
    for n=1:3
        object=SMASH.SignalAnalysis.Signal(varargin{n},varargin{4});
        if n==1
            t=object.Grid;
            table=repmat(object.Data,[1 3]);
        else
            table(:,n)=object.Data;
        end
    end       
else
    error('ERROR: invalid number of inputs');
end
clear object

% find lowest signal
[~,Q]=min(table,[],2); 

index=[1; find(Q(2:end) ~= Q(1:end-1))+1];
left=index(1:end-1);
right=index(2:end);
time=(t(left)+t(right))/2;

position=nan(size(time));
forward=(...
    ( (Q(left)==1) & (Q(right)==2)) | ...
    ( (Q(left)==2) & (Q(right)==3)) | ...
    ( (Q(left)==3) & (Q(right)==1)) );
position(forward)=+1/3;
position(~forward)=-1/3;

position=cumsum(position);

position=SMASH.SignalAnalysis.Signal(time,position);
position=-775e-9*position;
position.GridLabel='Time (s)';
position.DataLabel='Position (m)';

end