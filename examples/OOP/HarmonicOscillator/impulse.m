function F=impulse(t,t0,sigma)

if nargin<3
    sigma=1;
end

F=exp(-(t-t0).^2/(2*sigma^2));

end