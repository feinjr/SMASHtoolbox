% investigate Investigate statistical properties of a cloud
%
% This method investigates the statistical properties of a cloud using
% bootstrap analysis.  When called without outputs:
%      investigate(object);
% the plausible variations for the moments/correlations of each cloud
% variable are printed in the command window.  This invformation can also
% be returned as structures with fields "Lower" and "Upper".
%      [moments,correlations]=investigate(object).
%
% By default, 1000 bootstrap iterations are used to estimate 90% confidence
% regions.  These settings may be changed via additional inputs.
%      [...]=investigate(object,iterations,span);
% The number of boostrap iterations can be any integer larger than zero;
% this value should usually be at least 100 and can be increased well
% beyond the default value to stabilize the calculation (at the expense of
% speed).  The span input may be one or two numbers between 0.0 and 1.0;
% the former indicats indicates a centered span while the latter explicitly
% defines both sides of the span.  For example, a span of 0.90 indicates
% the central 90% (5% to 95%), which is equivalent to [0.05 0.95].
%
% See also Cloud, confidence, summarize
%

%
% created November 2, 2015 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=investigate(object,iterations,span)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=1000;
end
assert(SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
    'ERROR: invalid iterations setting');

if (nargin<3) || isempty(span)
    span=0.90;
end
assert(isnumeric(span) && isscalar(span),...
    'ERROR: invalid span setting');

% bootstrap analysis
Nvariables=object.NumberVariables;
Nmoments=size(object.Moments,2);
Ncorrelations=Nvariables*(Nvariables-1)/2;
Ncol=Nvariables*Nmoments+Ncorrelations;
table=nan(Ncol,iterations);

for k=1:iterations
    temp=bootstrap(object);
    % store moments
    index=1;
    for variable=1:Nvariables
        for moment=1:Nmoments
            table(index,k)=temp.Moments(variable,moment);
            index=index+1;
        end
    end
    % store correlations
    for m=1:Nvariables
        for n=(m+1):Nvariables
            table(index,k)=temp.Correlations(m,n);
            index=index+1;
        end
    end    
end

% process results
table=transpose(table);
new=SMASH.MonteCarlo.Cloud(table,'table');
bounds=confidence(new,span);

moments=struct();
moments.Lower=nan(Nvariables,Nmoments);
moments.Upper=moments.Lower;
index=1;
for variable=1:Nvariables    
    for moment=1:Nmoments
        moments.Lower(variable,moment)=bounds(1,index);
        moments.Upper(variable,moment)=bounds(2,index);
        index=index+1;
    end
end

correlations.Lower=eye(Nvariables,Nvariables);
correlations.Upper=correlations.Lower;
for m=1:Nvariables;
    for n=(m+1):Nvariables
        correlations.Lower(m,n)=bounds(1,index);
        correlations.Lower(n,m)=correlations.Lower(m,n);
        correlations.Upper(m,n)=bounds(2,index);
        correlations.Upper(n,m)=correlations.Upper(m,n);
        index=index+1;
    end
end

% manage output
if nargout==0
    % moments
    fprintf('Minimum statistical moments:\n');
    width=cellfun(@length,object.VariableName);
    width=max(width);
    format=['\t' sprintf('%%%ds',width) '%10s%10s%10s%10s\n'];
    fprintf(format,'','mean','variance','skewness','kurtosis');
    format=['\t' sprintf('%%%ds',width) '%#+10.3g%#+10.3g%#+10.3g%#+10.3g\n'];
    for n=1:Nvariables
        fprintf(format,object.VariableName{n},moments.Lower(n,:));
    end
    %
    fprintf('Maximum statistical moments:\n');    
    for n=1:Nvariables
        fprintf(format,object.VariableName{n},moments.Upper(n,:));
    end
    fprintf('\n');   
    % correlations
    fprintf('Minimum correlations:\n');
    format=repmat('%+10.3f ',[1 Nvariables]);
    format=['\t' format '\n'];
    fprintf(format,correlations.Lower);
    fprintf('Minimum correlations:\n');
    fprintf(format,correlations.Upper);
else
    varargout{1}=moments;
    varargout{2}=correlations;
end

end