% transform Apply transformation to a data coud
%
% This method transforms data in an existing cloud to a new cloud through a
% specified function
% Variables from the original cloud are passed to the function as a single
% input.  The function must return all transformations through a single
% output.  
%
% In standard mode:
%   result=transform(object,@myfunc); % defaults to standard mode 
%   result=transform(object,@myfunc,'standard);
% cloud data is passed to the transform function one point at a time.  If
% parallel processing is available, function evaluations for each point are
% distributed amongst MATLAB works; otherwise the transform function
% operates in a serial loop over all points.
%
% In vectorized mode:
%   result=transform(object,@myfunc,'vectorized');
% cloud data is passed to the tranform funtion all at once.  Vectorized
% transformations are usually faster than standard mode, but not all
% transformations can be vectorized.
%
% Ideally, the output object will have the same number of points as the
% input, but extreme outliers may be incompatible with the transform
% function.  When invalid input data is detected, the transform function
% should return an array where the first element is zero. These evaluations
% are removed from the result, so it is possible for the output object to
% contain fewer points than the input.
%
% See also Cloud
%

%
% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 6, 2014 by Daniel Dolan 
%    -fixed various bugs
% revised July 6, 2015 by Daniel Dolan
%    -cleaned up documentation and dealt with parallel processing changes
function result=transform(object,target,mode)

% handle input
if (nargin<2) || ~isa(target,'function_handle')
    error('ERROR: missing function handle');
end

if (nargin<3) || isempty(mode)
    mode='standard';
end

% check parallel state
parallel=false;
try
    if exist('matlabpool','file') && (matlabpool('size')>0) %#ok<DPOOL>
        parallel=true; % MATLAB 2013a and earlier
    end
catch
    if ~isempty(gcp('nocreate'))
        parallel=true; % MATLAB 2014a and later
    end
end

% apply target function to data table
table=object.Data;
switch lower(mode)
    case 'vectorized'
        out=feval(target,table);
    case 'standard'
        temp=feval(target,table(1,:));
        N=numel(temp);
        out=reshape(temp,[1 N]);
        M=object.NumberPoints;
        out=repmat(out,[M 1]);                  
        if parallel
            parfor m=2:M
                temp=feval(target,table(m,:));
                out(m,:)=reshape(temp,[1 N]);
            end
        else
            for m=2:M
                temp=feval(target,table(m,:));
                out(m,:)=reshape(temp,[1 N]);
            end
        end        
    otherwise
        error('ERROR: %s is an invalid mode',mode);
end

keep=~isnan(out(:,1));
out=out(keep,:);
result=SMASH.MonteCarlo.Cloud(out,'table');
result.Source='apply';

end