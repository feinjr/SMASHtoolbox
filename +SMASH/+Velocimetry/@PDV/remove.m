% remove Remove sinusoid from a PDV measurement
%
% This method removes a sinusoid:
%     s(t) = A cos(2*pi*f0*t) + B sin(2*pi*f0*t)
% from a PDV measurement.  The frequency and amplitudes of the sinusoid are
% determined from a target domain and then assumed to be valid for the
% entire measurement.
%     >> object=remove(object,[t1 t2]);
% The second input specifies the target domain, i.e. the minimum and
% maximum time during the sinusoid is to be minimized.
%
% By default, the sinusoid frequency (f0) is determined by the strongest
% component of the poewr spectrum in the target domain.  The value of f0
% can be restricted to the strongest component within a specficied
% frequency bound.
%     >> object=remove(object,[t1 t2],[f1 f2]);
% A reference domain can also be used to determine the sinusoid frequency.
%     >> object=remove(object,[t1 t2],[f1 f2],[tref1 tref2]);
% Frequency bounding is optional when a reference domain is specified.
%     >> object=remove(object,[t1 t2],[],[tref1 tref2]);
%
% The object returned by this method has the function s(t) subtracted over
% the entire time domain (regardless of limit settings).  The sinusoid
% parameters [f0 A B] are returned as a separate output.
%     >> [object,param]=remove(object,...);
%
% See also PDV
%

% created April 5, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function [object,param]=remove(object,target,bound,reference,options)

% handle input
if (nargin<2) || isempty(target)
    target=[-inf +inf];    
end
assert(isnumeric(target) & numel(target)==2,...
    'ERROR: invalid target domain');
target=sort(target);

if (nargin<3) || isempty(bound)
    bound=[0 inf];
end
assert(isnumeric(bound) & numel(bound)==2,...
    'ERROR: invalid frequency bound');

if (nargin<4) || isempty(reference)
    reference=target;
end
assert(isnumeric(reference) & numel(reference)==2,...
    'ERROR: invalid reference domaind');
reference=sort(reference);

if (nargin<5) || isempty(options)
    options=optimset;
end

% analyze reference domain
local=limit(object.Measurement,reference);
[f,P]=fft(local,'RemoveDC',true,'NumberFrequencies',1e6);

keep= (f>=bound(1)) & (f<=bound(2));
f=f(keep);
P=P(keep);

[Pmax,index]=max(P);
threshold=0.50*Pmax;
indexA=find(P(index-1:-1:1)<threshold,1,'first');
if isempty(indexA)
    indexA=0;
end
fA=f(index-indexA);
indexB=find(P(index+1:end)<threshold,1,'first');
if isempty(indexB)
    indexB=0;
end
fB=f(index+indexB);

% remove signal from target domain
local=limit(local,target);
[time,signal]=limit(local);
time=time(:);
signal=signal(:);
    function [chi2,amplitude,fit]=residual(frequency)
        phase=2*pi*frequency*time;
        basis=[cos(phase) sin(phase)];
        amplitude=basis\signal;
        fit=basis*amplitude;
        chi2=mean((signal-fit).^2);
    end
f0=fminbnd(@residual,fA,fB,options);
[~,amplitude]=residual(f0);

time=object.Measurement.Grid;
signal=object.Measurement.Data;
fit=amplitude(1)*cos(2*pi*f0*time)+amplitude(2)*sin(2*pi*f0*time);
object.Measurement=object.Measurement-fit;

param=[f0 amplitude(1) amplitude(2)];

end