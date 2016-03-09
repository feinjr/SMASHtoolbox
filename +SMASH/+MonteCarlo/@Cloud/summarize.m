% summarize Calculate actual moments and corelations
%
% This method summarizes the statistical properties of the Data stored in a
% Cloud object.  When called without outputs:
%     summarize(object);
% the moments array and correlation matrix are printed in the command
% window.  This information can also be returned as outputs.
%    >> [moments,correlations]=summarize(object);
%
% See also Cloud, confidence, investigate
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

% variable moments
moments=nan(object.NumberVariables,4);
for n=1:object.NumberVariables
    column=object.Data(:,n);
    moments(n,1)=sum(column)/object.NumberPoints; % mean
    column=column-moments(n,1);
    temp=column.*column;
    L=sum(temp)/object.NumberPoints;
    moments(n,2)=L; % variance 
    temp=temp.*column;
    moments(n,3)=sum(temp)/object.NumberPoints/(L^(3/2)); % skewness
    temp=temp.*column;
    moments(n,4)=sum(temp)/object.NumberPoints/(L^2)-3; % excess kurtosis
end

% variable correlations
correlations=corrcoef(object.Data);

% correlations=eye(object.NumberVariables);
% for m=1:object.NumberVariables    
%     columnM=object.Data(:,m)-moments(m,1);
%     columnM=columnM/sqrt(moments(m,2));
%     for n=(m+1):object.NumberVariables
%         columnN=object.Data(:,n)-moments(n,1);
%         columnN=columnN/sqrt(moments(n,2));
%         temp=sum(columnM.*columnN)/object.NumberPoints;
%         correlations(m,n)=temp;
%         correlations(n,m)=temp;
%     end
% end

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