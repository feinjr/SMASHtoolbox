function output=processReport(data)

names=fieldnames(data);
N=numel(names);
table=cell(1,N);
M=zeros(1,N);
for n=1:N
    temp=struct(names{n},data.(names{n})); %#ok<NASGU>
    command=sprintf('disp(temp)');
    table{n}=strtrim(evalc(command));
    M(n)=numel(table{n});
end

output=repmat(' ',[N max(M)]);
for n=1:N
    output(n,1:M(n))=table{n};
end

end