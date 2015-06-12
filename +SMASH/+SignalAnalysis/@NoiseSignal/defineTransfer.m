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
        
    case 'function'
        
    otherwise
        error('ERROR: invalid transfer mode');
end
%keep=(frequency>=0);
%object.TransferTable=[frequency(keep) transfer(keep)];
object.TransferTable=[frequency transfer];
object.TransferTable=sortrows(object.TransferTable,1);

end