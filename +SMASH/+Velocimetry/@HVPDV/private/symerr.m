% symerr Calculate symmetry error
%
%    chi2=symerr(ts,t,z);
%    chi2=symerr(ts); % use previous (t,z) values

function err=symerr(ts,time,signal)

if nargin==0
    time=1:(1/80):2;
    signal=cos(2*pi*2.75*time);
    ts=1.3;
    err=symerr(ts,time,signal);
    return
end

% calculate transforms as needed
persistent data
if nargin==1
    assert(~isempty(data),'ERROR: no (t,z) defined');
elseif nargin==3
    data.M=numel(time);
    assert(data.M == numel(signal),'ERROR: incompatible (t,z) data');
    %
    data.t0=time(1);
    data.t=time(:)-data.t0;
    %data.z=signal(:);
    data.z=1i*imag(signal(:));
    %data.z=real(signal(:));
    data.T=data.t(end)/(data.M-1);       
    %
    data.M2=pow2(nextpow2(numel(data.t))+2);
    %data.X=fft(real(data.z),data.M2);
    %data.Xstar=conj(data.X);
    %data.Y=fft(imag(data.z),data.M2);
    %data.Ystar=conj(data.Y);
    data.Z=fft(data.z,data.M2);
    data.Zstar=conj(data.Z);    
    %
    f=[0:(data.M2/2) (-data.M2/2+1):1:-1];
    data.f=f(:)/(data.M2*data.T);
else
    error('ERROR: invalid input');
end

% prepare symmetric location(s)
ts=ts-data.t0;
N=numel(ts);
ts=reshape(ts(:),[1 N]);
%yts=interp1(t,y,ts);

% calculate transfer matrices
arg=2i*pi*bsxfun(@times,data.f,ts);
A=exp(arg);
%B=exp(-arg);
B=1./A;

% calculate transform matrices
%Qx=bsxfun(@times,A,data.X)-bsxfun(@times,B,data.Xstar);
%Qy=bsxfun(@times,A,data.Y)+bsxfun(@times,B,data.Ystar);
Qz=bsxfun(@times,A,data.Z)-bsxfun(@times,B,data.Zstar);

if true
    err=real(Qz.*conj(Qz));
    err=sum(err)/numel(err);
else       
    % convert back to the time domain
     %qx=real(ifft(Qx,[],1));
     %qy=real(ifft(Qy,[],1));
     qz=ifft(Qz,[],1);
     t=(0:(data.M2-1))*data.T;    
     % calculate error
     err=real(qz.*conj(qz));
     err=trapz(t,err)/t(end);
end

end