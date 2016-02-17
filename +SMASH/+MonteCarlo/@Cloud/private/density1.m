% density1 One-dimensional probability density estimate
%

%
% created February 15, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=density1(data,GridPoints,SmoothFactor)

% manage input
assert(nargin>=1,'ERROR: insufficient input');
assert(all(isreal(data)),'ERROR: data table must be real');

assert(ismatrix(data),'ERROR: invalid data table');
data=data(:);
DataPoints=numel(data);

% SVD transformation
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
Vinv=transpose(V);

% create normalized grid(s)
width=std(data)/DataPoints^(1/5); % Silverman's rule
width=width*SmoothFactor;
span=max(abs(data))+5*width;
normgrid=linspace(-span,+span,GridPoints);
normgrid=normgrid(:);
dngrid=(normgrid(end)-normgrid(1))/(GridPoints-1);

% bin data into a discrete array
table=round((data-(normgrid(1)))/dngrid)+1;
index=(table<1);
table(index)=1;
index=(table>GridPoints);
table(index)=GridPoints;

Q=accumarray(table,1,[GridPoints 1]);

% estimate density
N2=pow2(nextpow2(GridPoints));
start=-N2/2;
stop=+N2/2-1;
k=(start:stop)/(N2*dngrid);
k=ifftshift(k(:));
Q(N2)=0; % zero padding
P=fft(Q);
P=P.*exp(-2*pi^2*width^2*k.^2);

weight=ifft(P,'symmetric');
weight=weight(1:GridPoints);
weight(weight<0)=0;

% map results to original coordinates
temp=normgrid*S*Vinv;
grid=linspace(min(temp),max(temp),GridPoints);
weight=interp1(temp,weight,grid);

weight=weight/trapz(grid,weight); % normalization

% manage output
if nargout==0
    figure;
    plot(grid,weight);
    xlabel('Data value');
    ylabel('Probability density');
else
    varargout{1}=grid;
    varargout{2}=weight;
    varargout{3}=struct('NormGrid',normgrid,'S',S,'Vinv',Vinv);
end

end