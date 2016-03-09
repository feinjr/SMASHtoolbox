% verify Verify cloud statistics
%
% This method verifies the statistical moments and correlations in a data
% cloud.  Confidence estimates are generated from bootstrap replications of
% the original cloud.
%    verify(object,iterations,span);
% The second and third inputs are optional.  By default, 1000 bootstrap
% iterations are used to estimate the 1-sigma span for every moment and
% correlation of the data cloud.  Spans may be specified as a centered
% width or as a low/high pair.
%    verify(object,iterations,0.90); % central 90% (5% to 95%)
%    verify(object,iterations,[0.025 0.975]); % 2.5% to 97.5% span
%
% Called this method with no outputs (as above) prints confidence region
% report to the command window.  Specifying an output:
%    report=verify(...);
% returns this report as a structure and suppresses printing.
%
% See also Cloud, summarize, confidence
%


%
% created March 9, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=verify(object,iterations,span)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=1000;
end
assert(isnumeric(iterations) && isscalar(iterations)...
    && (iterations>0) && (iterations==round(iterations)),...
    'ERROR: invalid iterations value');
if iterations<100
    warning('SMASH:Cloud','At least 100 iterations should be used to verify a cloud');
end

if (nargin<3) || isempty(span)
    span=erf(1/sqrt(2));
end
assert(isnumeric(span),'ERROR: invalid span value');
if numel(span)==1
    low=(1-span)/2;
    high=1-low;
else
    span=sort(span);
    low=span(1);
    high=span(2);
end
assert((low>0) && (high<1),'ERROR: span values')

% generate low/high index values
low=round(low*iterations);
low=max(low,1);

high=round(high*iterations);
high=min(high,iterations);

% bootstrap analysis
moment=nan(object.NumberVariables,4,iterations);
correlation=nan(object.NumberVariables,object.NumberVariables,iterations);
for k=1:iterations
    temp=bootstrap(object);
    moment(:,:,k)=temp.Moments;
    correlation(:,:,k)=temp.Correlations;
end

report=struct();
temp=nan(object.NumberVariables,4);
report.LowerMoment=temp;
report.UpperMoment=temp;
temp=diag(ones(1,object.NumberVariables));
temp(temp==0)=nan;
report.LowerCorrelation=temp;
report.UpperCorrelation=temp;
for m=1:object.NumberVariables
    for n=1:4
        temp=moment(m,n,:);
        temp=sort(temp(:));
        report.LowerMoment(m,n)=temp(low);
        report.UpperMoment(m,n)=temp(high);
    end
    for n=(m+1):object.NumberVariables
        temp=correlation(m,n,:);
        temp=sort(temp(:));
        report.LowerCorrelation(m,n)=temp(low);
        report.LowerCorrelation(n,m)=temp(low);
        report.UpperCorrelation(m,n)=temp(high);
        report.UpperCorrelation(n,m)=temp(high);
    end
end

% manage output
if nargout==0
    if numel(span)==1
        fprintf('Confidence region for %.3f span\n',span);
    else
        fprintf('Confidence region for %.2f-%.2f span\n',span(1),span(2));
    end
    % moments
    fprintf('Minimum statistical moments:\n');
    width=cellfun(@length,object.VariableName);
    width=max(width);    
    format=['\t' sprintf('%%%ds',width) '%10s%10s%10s%10s\n'];
    fprintf(format,'','mean','variance','skewness','kurtosis');
    format=['\t' sprintf('%%%ds',width) '%#+10.3g%#+10.3g%#+10.3g%#+10.3g\n'];
    for n=1:object.NumberVariables
        fprintf(format,object.VariableName{n},report.LowerMoment(n,:));
    end   
    fprintf('Maximum statistical moments:\n');
    width=cellfun(@length,object.VariableName);
    width=max(width);    
    format=['\t' sprintf('%%%ds',width) '%10s%10s%10s%10s\n'];
    fprintf(format,'','mean','variance','skewness','kurtosis');
    format=['\t' sprintf('%%%ds',width) '%#+10.3g%#+10.3g%#+10.3g%#+10.3g\n'];
    for n=1:object.NumberVariables
        fprintf(format,object.VariableName{n},report.UpperMoment(n,:));
    end    
    % correlations
    fprintf('Minimum correlations:\n');
    format=repmat('%+10.3f ',[1 object.NumberVariables]);
    format=['\t' format '\n'];
    fprintf(format,report.LowerCorrelation);
    fprintf('Maximum correlations:\n');
    format=repmat('%+10.3f ',[1 object.NumberVariables]);
    format=['\t' format '\n'];
    fprintf(format,report.UpperCorrelation);    
else
    varargout=report;
end

end