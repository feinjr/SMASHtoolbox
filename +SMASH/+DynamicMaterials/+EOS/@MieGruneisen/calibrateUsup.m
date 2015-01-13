% calibrate Calibrate Mie-Gruneisen model to a reference Hugoniot
%
% This method calibrates the Mie-Gruneisen Hugoniot parameters
%     >> object = calibruate(object,upData,UsData);
% where upData, UsData is the experimental principal Hugoniot. C0 and s are
% adjusted to provide a best fit to the data.
%
% See also MieGruneisen, evaluateHugoniot, evaluate
%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function object =calibrate(object,upData,UsData)

upData=upData(:);
UsData = UsData(:);

%Setup CurveFit object
fitobj=SMASH.CurveFit.Curve;
options=optimset('Display','final');
fitfun=@(p,x) p(1)+p(2).*x;
pIC = [object.c0,object.s];
p_lower = [object.c0*0.25, object.s*0.25];
p_upper = [object.c0*4.0, object.s*4.0];
fitobj = add(fitobj,fitfun,pIC,'lower',p_lower,'upper',p_upper,'FixScale',false);

%Fit CurveFit object and evaluate least squares error
fitobj = fit(fitobj,[upData(:) UsData(:)],options)
pFit = evaluate(fitobj,upData);
fp = fitobj.Parameter{:};
fs = fitobj.Scale{:};
fp(1)=fp(1).*fs;
fp(2)=fp(2).*fs;


lse = sqrt(sum((pFit-UsData).^2))

object.c0 = fp(1);
object.s = fp(2);

plot(upData,UsData,'ro',upData,pFit,'k');

end