% reveal method
%
%    >> reveal(object,name);
%
% See also namespace
%

%
%
%
function varargout=reveal(object,name)

h=[];
for n=numel(object.Names):-1:1
    if strcmp(object.Names{n},name);
        h=object.Handles{n};
        break
    end
end
assert(~isempty(h),'ERROR: invalid name');

% handle output
if nargout==0
    disp(h);
else
    varargout{1}=h;
end

end