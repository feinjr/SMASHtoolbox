function vf=flipRDM(v)

sizev=size(v);

if sizev(1)==1
    vf=fliplr(v);
elseif sizev(2)==1
    vf=flipud(v);
else
    vf=v;
    warning('Input was not a vector');
end

end