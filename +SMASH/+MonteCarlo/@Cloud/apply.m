% apply Apply function to Cloud data
%
% This method applies a specified function to each point in a data cloud.
% The result is a new cloud with the same number of rows as the source
% object.  The number of columns in the new cloud depends on the output
% array returned by the function.
%
% To use this function, pass a function handle as the second argument.
%   >> result=apply(object,target);
% The handle can point to an inline function:
%    >> result=apply(object,'@in in(1)+in(2)');
% or a function defined in a file.
%    >> result=apply(object,@myfunc);
% The evaluation function should accept a single input array and return a
% single output array.  The following example calculates both the sum and
% difference between the first to cloud variables.
% summation shown above.
%    function out=myfunc(in)
%    out=zeroes(1,2);
%    out(1)=in(1)+in(2);
%    out(2)=in(1)-in(2);;
%    end
% The result cloud is two-dimensional in this case, but there is no limit
% as to the number of output variables.
%
% This method has two modes for applying cloud data to the function.  In
% the standard "default" mode, MATLAB's parfor command is used to iterate
% through the cloud, evaluating the function at each cloud point.   If
% parallel processing is available and active, the evaluations are
% automatically divided amongst workers; for systems without parallel
% processing, the evaluation is performed serially.  A "vectorized"
% mode is provided for functions that can be vectorized, evaluating the
% entire table at once.  This mode is activated by passing a third input.
%    >> result=apply(object,@myfunc,'vectorized');
%
% Although extreme outliers may be rare, it is quite possible that a Cloud
% will contain contain points that are incompatible with the target
% function.  To handle this possibility, target functions may need to
% verify inputs before proceeding to their calculation.  When an invalid
% state is detected, the function should return an array matching the
% standard output size where the first element is NaN.  These evaluations
% are removed from the result, so it is possible for the output Cloud to
% have fewer points than the input Cloud.
%
% See also Cloud
%

%
% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 6, 2014 by Daniel Dolan 
%    -fixed various bugs
%
function result=apply(object,target,mode)

% handle input
if (nargin<2) || ~isa(target,'function_handle')
    error('ERROR: missing function handle');
end

if (nargin<3) || isempty(mode)
    mode='standard';
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
        if exist('matlabpool','file') && (matlabpool('size')>0)
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
result=SMASH.MonteCarlo.Cloud('table',out);
result.Source='apply';

end