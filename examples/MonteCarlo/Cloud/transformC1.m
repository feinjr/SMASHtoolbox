function out=transformC1(in)

out=zeros(1,2);

out(1)=in(1);

out(2)=in(1).^2./in(2);

end