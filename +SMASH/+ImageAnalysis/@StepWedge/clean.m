%
%

function object=clean(object,nhood)

% manage input
if (nargin<2) || isempty(nhood)
    nhood=9;
end

% perform median filter
object.Measurement=smooth(object.Measurement,'median',nhood);    

end