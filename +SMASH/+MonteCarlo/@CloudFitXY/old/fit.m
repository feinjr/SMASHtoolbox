%
% standard: 

function result=fit(object,target,mode)

% normalize data
[object,correction]=normalize(object);

% determine cloud weights
N=numel(object.Cloud);
weight=zeros(1,N);
for n=1:N
    x=object.Cloud{n}.Data(:,1);
    x=x-mean(x);
    y=object.Cloud{n}.Data(:,2);
    y=y-mean(y);
    L2=mean(x.^2+y.^2);
    weight(n)=1/L2;    
end

% generate master table
table=[];
for n=1:N
    temp=object.Cloud{n}.Data;
    temp(:,end+1)=weight(n); %#ok<AGROW>
    table=[table; temp;];     %#ok<AGROW>
end

% perform bootstrap analysis
M=size(table,1);
for iteration=1:object.Iterations
    m=randi(M,[M 1]);
    temp=table(m,:);
end

end