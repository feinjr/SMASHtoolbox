% result=draw(object);
%

%
%
%
function result=draw(object,number)

% handle input
if (nargin<2) || isempty(number)
    number=1;
else
    assert(isnumeric(number) & isscalar(number) & number>=1,...
        'ERROR: invalid number of draws');
    number=round(number);
end

% draw number from clouds
index=randi(object.NumberPoints,number);
result=object.Data(index,:);

end