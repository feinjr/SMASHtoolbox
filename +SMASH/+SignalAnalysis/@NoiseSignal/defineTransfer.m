% defineTransfer Define system transfer function
%
% This method defines the transfer function for the noise system.
%    object=defineTransfer(object,type,value);
% Several transfer types are supported.
%    -'nyquist' defines the system transfer to be constant from zero
%    frequency to the Nyquist frequency.  The input "value" is ignored.
%    -'fraction' defines the system transfer function to be constant from
%    zero frequency to some maximum frequency and zero otherwise.  The
%    input "value" defines the cutoff frequency as a fraction of the
%    Nyquist frequency.
%    -'bandwidth' defines the system transfer function by a simple low-pass
%    filter.  The input "value" defines the -3 dB point of this filter.
%    -'table' defines the transfer function by a two-column table.  The
%    first column of this table specifies frequency values and the second
%    column specifies transfer values at these frequencies.  Transfer
%    tables are passed through the input "value".
%    -'function' defines the system transfer by a user-specified function
%    handle.  This function must accept an array of frequency values and
%    return an array of transfer values (of the same size).
% The default type is 'nyquist'
%
% See also NoiseSignal, generate
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=defineTransfer(object,type,value)

% manage input
if (nargin<2) || isempty(type)
    type='nyquist';
end
assert(ischar(type),'ERROR: invalid transfer type');

if nargin<3
    value=[];
end
assert(isnumeric(value),'ERROR: invalid transfer value');

% generate table
frequency=-object.ReciprocalGrid;
keep=(frequency>=0);
frequency=frequency(keep);
transfer=zeros(size(frequency));
switch lower(type)
    case 'nyquist'
        index=(abs(frequency)<=(object.NyquistValue));
        transfer(index)=1;
    case 'fraction'
        assert(isscalar(value) && (value>0) && (value<=1),...
            'ERROR: invalid fraction value');
        index=(abs(frequency)<=(object.NyquistValue)*value);
        transfer(index)=1;
    case 'bandwidth'
        assert(isscalar(value) && (value>0),...
            'ERROR: invalid bandwidth value');
        transfer=1./(1+1i*(frequency/value));
    case 'table'
        assert(size(value,2)==2,...
            'ERROR: invalid transfer table');
        frequency=value(:,1);
        transfer=value(:,2);
        temp=interp1(frequency,transfer,[0 object.NyquistValue]);
        assert(~any(isnan(temp)),...
            'ERROR: transfer table does not span the complete frequency range');
    case 'function'
        if ischar(value)
            value=str2func(value);
        end
        assert(isa(value,'function_handle'),'ERROR: invalid transfer function');
        frequency=object.TransferTable(:,1);
        transfer=value(frequency);
    otherwise
        error('ERROR: invalid transfer mode');
end
object.TransferTable=[frequency transfer];
object.TransferTable=sortrows(object.TransferTable,1);

end