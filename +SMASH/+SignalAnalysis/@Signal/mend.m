% mend Remove NaN data from a Signal object
%
% This function removes NaN data in a Signal object.  
%    object=mend(object);
% NaN values bracketed by standard entries are replaced by linear
% interpolation; NaN entries that extent to the grid boundary are replaced
% with the first numeric value.
%
% NOTE: this method requires the Data property contain at least one numeric
% value!
%
% See also Signal, merge
%

%
% created January 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%

function object=mend(object)

% locate NaN values
indexA=isnan(object.Data); % NaN locations
assert(sum(indexA)<numel(indexA),'ERROR: no numeric values found');

N=numel(indexA);
indexB=~indexA; % numeric locations

% deal with boundaries
if indexA(1)    
    start=find(indexB,1,'first');
    value=object.Data(start);
    k=1:(start-1);
    object.Data(k)=value;
    indexA(k)=false;
    indexB(k)=true;
end

if indexA(end)
    start=find(indexB(N:-1:1),1,'first')-1;
    start=N-start;
    value=object.Data(start);
    k=(start+1):N;
    object.Data(k)=value;
    indexA(k)=false;
    indexB(k)=true;
end

% deal with everything else



end