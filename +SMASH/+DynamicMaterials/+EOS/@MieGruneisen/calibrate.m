% calibrate Calibrate Mie-Gruneisen model to a reference Hugoniot
%
% This method calibrates the Mie-Gruneisen Hugoniot parameters
%
%     >> object = calibruate(object,rhoData,pData);
%
% where rhoData, pData is the experimental principal Hugoniot. C0 and s are
% adjusted to provide a best fit to the data.
%
% Bounds on the parameters may be given as
%
%     >> object = calibruate(object,rhoData,pData, p_lower, p_upper);
% 
% where p_l is a vector corresponding to [C0_l, s_l].
%
% See also MieGruneisen, calibrateUsup, evaluateHugoniot, evaluate

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function object =calibrate(object,rhoData,pData,varargin)

pIC = [object.c0,object.s];
p_lower = [object.c0*0.25, object.s*0.25];
p_upper = [object.c0*4.0, object.s*4.0];

%Bounds specification
if nargin > 3
    p_lower = varargin{1};
end
if nargin > 4
    p_upper = varargin{2};
end

rhoData=rhoData(:);
pData = pData(:);
T0=object.T0;

%Setup CurveFit object
fitobj=SMASH.CurveFit.Curve;
options=optimset('Display','final');
fitfun=@(p,x) calculateHugoniot(object,x,p);
fitobj = add(fitobj,fitfun,pIC,'lower',p_lower,'upper',p_upper,'FixScale',false);

%Fit CurveFit object and evaluate least squares error
fitobj = fit(fitobj,[rhoData(:) pData(:)],options)
pFit = evaluate(fitobj,rhoData);
fp = fitobj.Parameter{:};
fs = fitobj.Scale{:};
fp(1)=fp(1).*sqrt(fs);

object.c0 = fp(1);
object.s = fp(2);

%lse = sqrt(sum((pFit-pData).^2))
%plot(rhoData,pData,'ro',rhoData,pFit);

end