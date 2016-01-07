% isParallel Determine if parallel processing is available
%
% This function determines if parallel processing is available on the
% current system.  
%    result=isParallel();
% The output is true when the Parallel Processing Toolbox is present *and*
% multiple workers are enabled.
% 
% See also System
%

%
% created January 7, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function result=isParallel()

result=false;
try
    if exist('matlabpool','file') && (matlabpool('size')>0) %#ok<DPOOL>
        result=true; % MATLAB 2013a and earlier
    end
catch
    if ~isempty(gcp('nocreate'))
        result=true; % MATLAB 2014a and later
    end
end

end