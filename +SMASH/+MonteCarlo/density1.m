% density1 One-dimensional probability density estimate
%
% This function estimates the underlying probability density from a
% one-dimensional data set.
%    [grid,weight]=density1(data); % return density
%    density(data);                % plot density
% Density calculation is performed with Gaussian kernels using an
% automatically determined width.
%
% Calculation options are specified by name/value pairs
%    [...]=density1(data,name,value,...);
% Valid option names are:
%    -'GridPoints'   : number of grid points (default = 100)
%    -'SmoothFactor' : kernel smoothing factor (default = 1)
%
% See also MonteCarlo
%

%
% created February 15, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=density1(data,varargin)

% manage input
assert(nargin>=1,'ERROR: insufficient input');
assert(all(isreal(data)),'ERROR: data table must be real');

assert(ismatrix(data),'ERROR: invalid data table');
data=data(:);
DataPoints=numel(data);

import SMASH.General.testNumber;
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
setting=struct('GridPoints',100,'SmoothFactor',1);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid setting name');
    value=varargin{n+1};
    switch lower(name)
        case 'gridpoints'
            assert(...
                testNumber(value,'integer','positive','notzero'),...
                'ERROR: invalid number of grid points');
            setting.GridPoints=value;
        case 'smoothfactor'
            assert(...
                testNumber(value,'positive','notzero'),...
                'ERROR: invalid smooth factor');
            setting.SmoothFactor=value;        
        otherwise
            error('ERROR: invalid setting name');
    end
end

% SVD transformation
center=mean(data,1);
data=bsxfun(@minus,data,center);

[data,S,V]=svd(data,0);
%Sinv=diag(1./diag(S));
Vinv=transpose(V);

% create normalized grid(s)
width=std(data)/DataPoints^(1/5); % Silverman's rule
width=width*setting.SmoothFactor;
span=max(abs(data))+5*width;
normgrid=linspace(-span,+span,setting.GridPoints);
normgrid=normgrid(:);
dngrid=(normgrid(end)-normgrid(1))/(setting.GridPoints-1);

% bin data into a discrete array
table=round((data-(normgrid(1)))/dngrid)+1;
index=(table<1);
table(index)=1;
index=(table>setting.GridPoints);
table(index)=setting.GridPoints;

Q=accumarray(table,1,[setting.GridPoints 1]);

% estimate density
N2=pow2(nextpow2(setting.GridPoints));
start=-N2/2;
stop=+N2/2-1;
k=(start:stop)/(N2*dngrid);
k=ifftshift(k(:));
Q(N2)=0; % zero padding
P=fft(Q);
P=P.*exp(-2*pi^2*width^2*k.^2);

weight=ifft(P,'symmetric');
weight=weight(1:setting.GridPoints);
weight(weight<0)=0;

% map results to original coordinates
temp=normgrid*S*Vinv;
grid=linspace(min(temp),max(temp),setting.GridPoints);
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