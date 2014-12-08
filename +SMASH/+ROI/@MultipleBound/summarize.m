function varargout=summarize(object)

N=numel(object.BoundArray);
name=cell(1,N);
type=cell(1,N);

for n=1:N
    temp=object.BoundArray{n};
    type{n}=class(temp);
    match=regexp(type{n},'[.]');
    if numel(match)>0
        match=match(end);
        type{n}=type{n}(match+1:end);
    end
    name{n}=temp.Label;
end

% handle output
if nargout==0
    if N==0
        fprintf('Object is empty\n');
        return
    end
    fprintf('Object contains %d boundaries\n',N);
    width=floor(log10(N))+1;
    format=sprintf('   %%%dd: %%s (%%s)\\n',width);
    for n=1:N
        fprintf(format,n,name{n},type{n});
    end
else
    varargout{1}=name;
    varargout{2}=type;
end

end