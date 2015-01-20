% calibrateGamma Calibrate Debye objects's gamma function
%
% This method calibrates the Debye object's gamma parameters
%
%     >> object = evaluate(object,rhoData,gammaData);
%
% where rhoData, gammaData is the data set to fit to. 
% Bounds on the parameters can be specified with arrays of p_lower and
% p_upper as
%
%     >> object = evaluate(object,rhoData,gammaData,p_lower,p_upper);
%
% See also Debye, evaluate, evaluateGamma

%
% created January 15, 2014 by Justin Brown (Sandia National Laboratories)
%
function object = calibrateGamma(object,rhoData,gammaData,varargin)


pIC = object.p;
p_lower = object.p*0.1;
p_upper = object.p*10; 

%Bounds specification
if nargin > 3
    p_lower = varargin{1};
end
if nargin > 4
    p_upper = varargin{2};
end
    

%Setup CurveFit object
fitobj=SMASH.CurveFit.Curve;
options=optimset('Display','final');
fitfun=@(p,x) calculateDebyeTemp(object,x,p);
fitobj = add(fitobj,fitfun,pIC,'lower',p_lower,'upper',p_upper,'FixScale',true);

%Fit CurveFit object and evaluate least squares error
fitobj = fit(fitobj,[rhoData(:) gammaData(:)],options);
sfit = evaluate(fitobj,rhoData);
object.p = fitobj.Parameter{:};

lse = sqrt(sum((sfit-gammaData).^2))
plot(rhoData,gammaData,'ro',rhoData,sfit,'k')

end