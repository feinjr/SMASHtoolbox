% FITELLIPSE - Calculates the best ellipse parameters for a VISAR object
%
% This method calculates the ellipse fitting parameters for a VISAR object 
% using the ellipse fitting functions written by Dan Dolan for PointVISAR.  
% This is just a front end to those scripts.  Details of the algorithms can
% be found in the DirectEllipseFit.m and IterativeEllipseFit.m files in the
% private directory of Point VISAR. Teh possible syntaxes are listed below.
%      >> object=fitEllipse(object,method,fixed);
%      >> object=fitEllispe(object,method);
%      >> object=fitEllipse(object,fixed);
%      >> object=fiteEllipse(object);
%
% Method defines how the ellipse parameters are determined.
%      'Iterative' - The ellispe parameters are determined through
%                    iteration.  This is the default.
%      'Direct'    - Makes an inital guess for the ellipse parameters
%
% Fixed determines which, if any, of the ellipse parameters are to be held
% constant during fitting.  This is passed in as an 1x5 array:  0
% signifies that variable that are allowed to change.  Any other number
% signifies the variable is fixed.  The default is no fixed variables.
%
% created March 16 2016 by Paul Specht (Sandia National Laboratories) 

function object=fitEllipse(object,method,fixed)

%handle input
if nargin == 1
    method='iterative';
    fixed=zeros(1,5);
elseif nargin == 2
    if isnumeric(method);
        fixed=method;
        if numel(fixed) ~= 5
            error('ERROR: Invalid Fixed Parameter Specficiation.  Must be a 5 Element Array.');
        else
            method='iterative';
        end
    elseif strcmpi(method,'iterative') || strcmpi(method,'direct')
        fixed=zeros(1,5);
    else
        error('ERROR: Invalid Fitting Method');
    end
elseif nargin == 3
    if isnumeric(fixed)
        if numel(fixed) ~= 5
            error('ERROR: Invalid Fixed Parameter Specficiation.  Must be a 5 Element Array.');
        end
    else
        error('ERROR: Invalid Fixed Parameter Specficiation.  Must be a 5 Element Array.');
    end
end
fixed=(fixed ~= 0);

assert(isa(object.Quadrature,'SMASH.SignalAnalysis.SignalGroup'),...
    'ERROR: Must Preprocess Signal to View');
X=object.Quadrature.Data(:,1);
Y=object.Quadrature.Data(:,2);
params=object.EllipseParameters;
if strcmpi(method,'Direct')
    efit=DirectEllipseFit(X,Y);
    saved=params.*fixed;
    new=efit.*(fixed == 0);
    object.EllipseParameters=saved+new;
elseif strcmpi(method,'Iterative')
    efit=IterativeEllipseFit(X,Y,params,fixed);
    object.EllipseParameters=efit;
else
    error('ERROR: Invalid Ellipse Fitting Method');
end
    
    
    
    


    