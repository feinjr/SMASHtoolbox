function y=CrudeVoigt(param,x)

% initial setup
x0=param(1);
sigma=param(2);
gamma=param(3);

% horizontal normalization
L=max(x)-min(x);
L=max(L,sigma);
L=max(L,gamma);

sigma=sigma/L;
gamma=gamma/L;

% integration
u=(x-x0)/L;
kernel=@(v) exp(-v.^2/(2*sigma^2))./(1+(u-v).^2/gamma^2);
y=integral(kernel,-inf,+inf,'ArrayValued',true);

% normalization
u=0;
kernel=@(v) exp(-v.^2/(2*sigma^2))./(1+(u-v).^2/gamma^2);
y=y/integral(kernel,-inf,+inf);

end