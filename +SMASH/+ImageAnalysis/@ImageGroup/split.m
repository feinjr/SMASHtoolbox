% SPLIT Divide ImageGroup into Image objects
%
% This method breaks up an ImageGroup object into a collection of Image
% objects.
%    >> [object1,object2,...]=split(object)
%
% See also SignalGroup, gather
%

%
% created January 7, 2016 by Sean Grant (Sandia National Laboratories/UT)
%

function varargout=split(object)

assert(nargout<=object.NumberImages,...
    'ERROR: too many outputs requested');
varargout=cell(1,object.NumberImages);

[bound1,bound2]=limit(object);
bound1=[min(bound1) max(bound1)];
bound2=[min(bound2) max(bound2)];
for n=1:object.NumberImages
    varargout{n}=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,n));
    varargout{n}=limit(varargout{n},bound1,bound2);
    varargout{n}.Source='ImageGroup split';    
end

end