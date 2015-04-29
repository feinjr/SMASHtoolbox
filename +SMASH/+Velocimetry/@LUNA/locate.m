function varargout=locate(object,width,region)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(isnumeric(width) && isscalar(width) && width>0,...
    'ERROR: invalid width');

if (nargin<3) || isempty(region)
    region=[0 max(object.Time)];
end
assert(isnumeric(region) && numel(region)==2,...
    'ERROR: invalid region');
region=sort(region);

% perform local search
x=object.Time;
y=object.LinearAmplitude;
index=(x>=region(1)) & (x<=region(2));
x=x(index);
y=y(index);

dx=(x(end)-x(1))/(numel(x)-1);
L=ceil(width/dx);
kernel=ones(L,1);
z=conv(y,kernel,'same');
[~,k]=max(z);
time=x(k);

k=abs(x-time)<=(width/2);
area=trapz(x(k),y(k));
% factor of two correction may be needed to account for round trip timing!
c0=299792458/object.FileHeader.GroupIndex; % m/s
c0=c0*1e3/1e9; % mm/ns
area=c0*area;

% manage output
if nargout==0
    view(object);
    xlim(time+[-1 +1]*width/2)
    label=sprintf('t0=%.3f ns, RL=%.0f dB',time,-10*log10(area));
    title(label);
else
    varargout{1}=time;
    varargout{2}=area;
end

end