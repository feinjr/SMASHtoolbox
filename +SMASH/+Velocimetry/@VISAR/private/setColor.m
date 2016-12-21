% setColor : sets line colors
% created 10/19/2016  by Paul Specht
%
%
% This function sets the line colors for the VISAR view method

function setColor(handle,Colors,type,k)
if type < 2
    int=4;
elseif type == 3
    int=2;
else
    int=1;
end
for n=1:length(handle)
    set(handle(n),'Color',Colors(n+int*(k-1),:));
end

end