% summarize Calculate actual moments and corelations
%
% This method summarizes the statistical properties of the Data stored in a
% Cloud object.  When called without outputs:
%     summarize(object);
% the moments array and correlation matrix are printed in the command
% window.  This information can also be returned as outputs.
%    >> [moments,correlations]=summarize(object);
%
% See also Cloud, confidence
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

% variable moments
moments=nan(object.NumberVariables,4);
for n=1:object.NumberVariables
    column=object.Data(:,n);
    moments(n,1)=mean(column); % mean
    column=column-moments(n,1);
    L=var(column);
    moments(n,2)=L; % variance
    moments(n,3)=mean(column.^3)/(L^(3/2)); % skewness
    moments(n,4)=mean(column.^4)/(L^2)-3; % excess kurtosis
end

% variable correlations
correlations=corrcoef(object.Data);

% handle output
if nargout==0
    fprintf('Statistical moments:\n');
    width=cellfun(@length,object.VariableName);
    width=max(width);    
    format=['\t' sprintf('%%%ds',width) '%10s%10s%10s%10s\n'];
    fprintf(format,'','mean','variance','skewness','kurtosis');
    format=['\t' sprintf('%%%ds',width) '%#+10.3g%#+10.3g%#+10.3g%#+10.3g\n'];
    for n=1:object.NumberVariables
        fprintf(format,object.VariableName{n},moments(n,:));
    end    
   
    fprintf('Correlations:\n');
    format=repmat('%+10.3f ',[1 object.NumberVariables]);
    format=['\t' format '\n'];
    fprintf(format,correlations);
else
    varargout{1}=moments;
    varargout{2}=correlations;
end

end