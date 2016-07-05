% Thin the responses used to build the Gaussian Process
%
% This thins the responses used to build the Gaussian Process.
%
%    >> object=thinResponses(object,x);
% 
% If x is 1D array then it represents the elements to kept.  
% If x is a scalar, then it is taken to be a stride such that the 
% build points kept are 1:x:end
%
% See also GP, evaluate
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
function object=thinResponses(object,x)

if ~isvector(x) && ~isscalar(x)
    error('ERROR : x must be a scalar or 1D array');
end

    
if isscalar(x)
    [nrow ncol] = size(object.ResponseData);
    thin = 1:x:ncol;
    object.ResponseData = object.ResponseData(:,thin);
    object.ResponseNames = object.ResponseNames(thin);
    object.Grid = object.Grid(thin);
else
    thin = x;
    object.ResponseData = object.ResponseData(:,thin);
    object.ResponseNames = object.ResponseNames(thin);
    object.Grid = object.Grid(thin);
end

[nbuild nresp] = size(object.ResponseData);
object.NumberResponses = nresp;

end
