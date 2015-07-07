% confidence Calculate confidence regions
%
% This method estimates confidence regions for each variable in a data
% cloud.  By default, a 1-sigma span centered at the median is used, but
% custom regions can also be specified.
%
% Examples:
%   >> result=confidence(object); % 1-sigma span (centered at 50%)
%   >> result=confidence(object,0.90); % 90% confidence span (centered at 50%)
%   >> result=confidence(object,[0.10 0.95]); % custom span from 10% to 95%
%
% See also Cloud, summarize
%

% created June 29, 2013 by Daniel Dolan (Sandia National Laboratories)
function varargout=confidence(object,span)

% handle input
if (nargin<2) || isempty(span)
    span=erf(1/sqrt(2));
elseif any(span<=0) || any(span>=1)
    error('ERROR: confidence span must be greater than zero and less than one');
end

if numel(span)==1
    low=(1-span)/2;
    high=1-low;
else
    low=span(1);
    high=span(2);
end

% error checking
if low<=0
    error('ERROR: lower confidence bound must be greater than zero');
end
if high>=1
    error('ERROR: upper confidence bound must be less than one');
end

% identify confidence domain
limit=round(object.NumberPoints*[low high]);
result=nan(2,object.NumberVariables);
for n=1:object.NumberVariables
    temp=sort(object.Data(:,n));
    result(1,n)=temp(limit(1));
    result(2,n)=temp(limit(2));
end
result=result(~isnan(result));
result=reshape(result,2,[]);

% handle output
if nargout==0
    if numel(span)==1
        fprintf('Confidence region for %.3f span\n',span);
    else
        fprintf('Confidence region for %.2f-%.2f span\n',span(1),span(2));
    end
    width=cellfun(@length,object.VariableName);
    width=max(width);
    format=['\t' sprintf('%%%ds',width) '%10s%10s\n'];
    fprintf(format,'','Lower','Upper');
    format=['\t' sprintf('%%%ds',width) '%#+10.3g%#+10.3g\n'];
    for n=1:object.NumberVariables
        fprintf(format,object.VariableName{n},result(1,n),result(2,n));
    end    
end

if nargout>=1
    varargout{1}=result;
end

end