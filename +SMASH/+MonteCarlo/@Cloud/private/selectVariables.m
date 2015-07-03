
function variable=selectVariables(object,N,match)

if (nargin<3) || isempty(match)
    match='true';    
end
if strcmpi(match,'true') || strcmpi(match,'match')
    match=true;
else
    match=false;
end

if object.NumberVariables<=N
    variable=1:object.NumberVariables;
else
    prompt={};
    prompt{end+1}=sprintf('This object contains %d variables',...
        object.NumberVariables);
    if match
        prompt{end+1}=sprintf('Select %d variables: ',N);
    else
        prompt{end+1}=sprintf('Select up to %d variables: ',N);
    end
    prompt=sprintf('%s\n%s',prompt{:});
    while true
        variable=input(prompt,'s');
        [variable,count]=sscanf(variable,'%d');
        if (match && (count==N)) 
            break
        elseif (~match) && (count<=N)
            break
        end
    end
end
variable=transpose(variable(:));


end