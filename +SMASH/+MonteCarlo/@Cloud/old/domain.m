% estimate confidence domains(s) in a data cloud
%
%   >> result=confidence(object,'span',?);
%

%
function result=domain(object,varargin)

% handle input
span=erf(1/sqrt(2));
variable=1:object.NumberVariables;
for n=1:2:numel(varargin)
    name=varargin{n};
    value=varargin{n+1};
    switch lower(name)
        case 'span'
            span=value;
        case 'variable'
            variable=value;
    end
end

if (span>=1) || (span<=0);
    error('ERROR: span must be greater than zero and less than unity');
end

% identify confidence domain
low=(1-span)/2;
high=1-low;
limit=round(object.NumberPoints*[low high]);
result=nan(2,object.NumberVariables);
for n=variable
    temp=sort(object.Data(:,n));
    result(1,n)=temp(limit(1));
    result(2,n)=temp(limit(2));
end
result=result(~isnan(result));
result=reshape(result,2,[]);

end