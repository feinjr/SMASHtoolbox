% summarize Sumarize object contents
% 
% This method summarizes the contents of a group.
%     >> summarize(group); % results printed to command window
%     >> name=summarize(group); % object names returned as an output
% 
% See also BoundingCurveGroup, view
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

N=numel(object.Children);
name=cell(1,N);

for n=1:N
    temp=object.Children{n};   
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
    format=sprintf('   %%%dd: %%s \\n',width);
    for n=1:N
        fprintf(format,n,name{n});
    end
else
    varargout{1}=name;
end

end