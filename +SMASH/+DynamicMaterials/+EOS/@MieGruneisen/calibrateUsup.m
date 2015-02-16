% calibrate Calibrate Mie-Gruneisen model to a reference Hugoniot
%
% This method calibrates the Mie-Gruneisen Hugoniot parameters
%
%     >> object = calibruate(object,upData,UsData);
%
% where upData, UsData is the experimental principal Hugoniot. C0 and s are
% adjusted to provide a best fit to the data.
%
% Bounds on the parameters may be given as
%
%     >> object = calibruate(object,rhoData,pData, p_lower, p_upper);
% 
% where p_l is a vector corresponding to [C0_l, s_l].
%
% See also MieGruneisen, calibrate, evaluateHugoniot, evaluate, mixHugoniot

%
% created January 9, 2014 by Justin Brown (Sandia National Laboratories)
%
function object =calibrate(object,upData,UsData,varargin)

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

upData=upData(:);
UsData = UsData(:);

%Setup CurveFit object
fitobj=SMASH.CurveFit.Curve;
options=optimset('Display','final');
fitfun=@(p,x) p(1)+p(2).*x;
fitobj = add(fitobj,fitfun,pIC,'lower',p_lower,'upper',p_upper,'FixScale',false);

%Fit CurveFit object and evaluate least squares error
fitobj = fit(fitobj,[upData(:) UsData(:)],options);
pFit = evaluate(fitobj,upData);
fp = fitobj.Parameter{:};
fs = fitobj.Scale{:};
fp(1)=fp(1).*fs;
fp(2)=fp(2).*fs;

object.c0 = fp(1);
object.s = fp(2);

%lse = sqrt(sum((pFit-UsData).^2))
%plot(upData,UsData,'ro',upData,pFit,'k');

end