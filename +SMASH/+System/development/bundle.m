function bundle(name,mode)

% handle input
if nargin<2
    mode='mcode';
end

% dependency test
list=depfun(name);

end