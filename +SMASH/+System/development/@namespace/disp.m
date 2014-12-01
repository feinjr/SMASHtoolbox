% custom object display
function disp(object)

name=object.Names;
N=numel(name);
fprintf('namespace containing %d names:\n',N);

tab=repmat(' ',[1 3]);
WindowSize=get(0,'CommandWindowSize');
col=floor(min(WindowSize(1)/N));
format=sprintf('%%-%ds ',N);
format=repmat(format,[1 col]);
format=[tab format];
while numel(name)>0
    N=min([col numel(name)]);
    fprintf(format,name{1:N});
    fprintf('\n');
    name=name(col+1:end);
end
fprintf('\n');

end