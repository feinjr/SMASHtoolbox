function out=transformBvectorized(in)

Npoints=size(in,1);

out=zeros(Npoints,2);

out(:,1)=in(:,1)+in(:,2);

out(:,2)=in(:,2)+in(:,3);

end