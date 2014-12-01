% compare Determine of cloud variables are statistcally distinct
%
% This method compares two Cloud objects having the same number of
% variables.  For each variable, a distribution of median differences is
% internally constructed to determine if the objects are statistically
% distinct.  When called without outputs:
%    >> compare(reference,target);
% the method generates a report indicating distinct and non-distinct
% variables between the two objects ("reference" and "target").  The
% default analysis uses 100 bootstrap iterations and a 95% span; these
% settings are controlled with additional inputs.
%    >> compare(reference,target,iterations,span); % 0 < span < 1
% Specifying an output:
%    >> result=compare(...);
% suppresses the report and returns an array indicating distinct variables
% with logical "true" value.
%
% See also Cloud, confidence, summarize
%

% created July 21, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 8, 2014 by Daniel Dolan
%    -changed from intra-cloud to inter-cloud comparison
%    -revised bootstrap approach (could use vectorization)
%
function varargout=compare(reference,target,iterations,span)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');
assert(isa(target,'SMASH.MonteCarlo.Cloud'),...
    'ERROR: invalid target object');
assert(reference.NumberVariables==target.NumberVariables,...
    'ERROR: incompatible objects');
Nvar=reference.NumberVariables;

if (nargin<3) || isempty(iterations)
    iterations=100;
end
assert(SMASH.General.testNumber(iterations,'positive','integer'),...
    'ERROR: invalid number of iterations')

if (nargin<4) || isempty(span)
    span=0.95;
end

% bootstrap evaluations
statistic=@(table) median(table,1);
table=nan(iterations,Nvar);
for k=1:iterations
    A=bootstrap(reference);
    B=bootstrap(target);
    table(k,:)=statistic(A.Data)-statistic(B.Data);
end

% process evaluations
alpha=(1-span)/2;
indexA=round(alpha*iterations);
indexB=round((1-alpha)*iterations);
[lower,upper,distinct]=deal(nan(1,Nvar));
for m=1:Nvar
    column=sort(table(:,m));
    lower(m)=column(indexA);
    upper(m)=column(indexB);
    if (lower(m)<=0) && (upper(m)>=0)
        distinct(m)=false;
    else
        distinct(m)=true;
    end
end


% handle output
if nargout==0
    fprintf('Cloud comparison:\n');
    for m=1:Nvar        
        if distinct(m)
            fprintf('\tVariable %d is statistically distinct at the %.2f span\n',m,span);
        else
           fprintf('\tVariable %d is NOT statistically distinct at the %.2f span\n',m,span); 
        end
    end
else
    varargout{1}=distinct;
    varargout{2}=lower;
    varargout{3}=upper;
    varargout{4}=span;
end

end