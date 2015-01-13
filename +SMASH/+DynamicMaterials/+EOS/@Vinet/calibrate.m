% calibrate Calibrate Vinet model to a reference isotherm
%
% This method calibrates the Vinet object reference curve to a specified
% isotherm.
%     >> object = evaluate(object,rhoData,pData);
% where rhoData, pData is the experimental isotherm (generally DAC) to be
% calibrated to. The length of the intial d array determines the
% amount of coeffients used.
%
% See also Vinet, evaluate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function object =calibrate(object,rhoData,pData)

rhoData=rhoData(:);
pData = pData(:);
T0=object.T0;

%Setup CurveFit object
fitobj=SMASH.CurveFit.Curve;
options=optimset('Display','final');
fitfun=@(p,x) calculateVinet(object,x,T0,p);
pIC = [object.B0,object.BP0,object.d];
p_lower = [object.B0*0.5, object.BP0*0.5, object.d-1000];
p_upper = [object.B0*2.0, object.BP0*2.0, object.d+1000];
fitobj = add(fitobj,fitfun,pIC,'lower',p_lower,'upper',p_upper,'FixScale',false);

%Fit CurveFit object and evaluate least squares error
fitobj = fit(fitobj,[rhoData(:) pData(:)],options);
sfit = evaluate(fitobj,rhoData);
fp = fitobj.Parameter{:};
fs = fitobj.Scale{:};
fp(1)=fp(1).*fs;

lse = sqrt(sum((sfit-pData).^2))

object.B0 = fp(1);
object.BP0 = fp(2);
if length(fp) > 2
    object.d = fp(3:end);
end

end