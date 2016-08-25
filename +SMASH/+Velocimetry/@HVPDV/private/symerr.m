% symerr Calculate symmetry error
%
%    chi2=symerr(ts,t,z);
%    chi2=symerr(ts); % use previous (t,z) values

function err=symerr(ts,time,signal)

if nargin==0
    time=1:(1/80):2;
    signal=cos(2*pi*2.75*time);
    ts=1.3;
    symerr(ts,time,signal);
    return
end

% calculate transforms as needed
persistent M M2 f Zplus Zminus T left right t z
if nargin==1
    assert(~isempty(M),'ERROR: no (t,z) defined');
elseif nargin==3
    M=numel(time);
    assert(M == numel(signal),'ERROR: incompatible (t,z) data');
    %
    left=time(1);
    right=time(end);
    t=time(:)-left;     
    T=t(end)/(M-1);       
    z=signal(:);
    %        
    zpad=[z; z(end-1:-1:2)];
    M2=pow2(nextpow2(numel(zpad))+1);
    zpad(M2+1)=0;
    zpad=[zpad; zpad(end-1:-1:2)];
    M2=numel(zpad);
    f=[0:(M2/2) (-M2/2+1):1:-1];
    f=f(:)/(M2*T);    
    Zplus=fft(zpad,M2);
    Zminus=fft(conj(zpad),M2);
else
    error('ERROR: invalid input');
end

% verify symmetry location
ts=ts-left;
N=numel(ts);
ts=reshape(ts(:),[1 N]);

% calculate transfer matrices
arg=2i*pi*bsxfun(@times,f,ts);
Aplus=exp(arg);
Aminus=exp(-arg);

% calculate transform matrix and convert back to time domain
Q1=bsxfun(@times,Aplus,Zplus);
Q2=bsxfun(@times,Aminus,Zminus);
q=ifft(Q1-Q2,[],1);
q=q(1:M,:);
tq=(0:(M-1))*T;

% calculate error
err=real(q.*conj(q));
err=trapz(err)/tq(end);
drop=(ts <= 0) | (ts >= t(end));
err(drop)=nan;

% if nargout==0
%     subplot(3,1,1);
%     tz=(0:((numel(z)-1)))*T;
%     plot(tz,z);
%     line(repmat(ts,[1 2]),ylim,'Color','k');
%     subplot(3,1,2);
%     plot(tq,real(ifft(Q1)),tq,real(ifft(Q2)));    
%     subplot(3,1,3);
%     plot(tq,abs(q));
%     %line(repmat(ts,[1 2]),ylim,'Color','k');
%     %line(repmat(t(end)-ts,[1 2]),ylim,'Color','k');
% end

end