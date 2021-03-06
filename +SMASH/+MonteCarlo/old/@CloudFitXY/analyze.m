% analyze Perform curve fit analysis
%
% This method launches curve fit analysis.  The calling syntax is:
%    >> result=analyze(object,curve,guess,[evaluation],...);
% where the "curve" and "guess" inputs are mandatory.  "curve" specifies
% the fit function of interest.  This function *must* have the format:
%     [x,y]=myfunc(param,evalpoints)
% The first input is an array of adjustable model parameters.  The second
% input is a set of evaluation points for the curve.  In many cases, the
% evaluation points are identical to x, but this is not mandatory.  The fit
% function can modify the evaluation points to capture important
% features (such as breaks), or the function could be parametric in
% nature, i.e. x=x(t), y=y(t).  The "guess" input tells the analysis the
% number of adjustable parameters and serves as the starting point for all
% optimizations.  If no evaluation points are specified, the analysis
% assumes that the function is of the form y=f(x) and that x spans the
% range of data points within the object.
%
% All additional inputs to this method are treated as control options for
% the optimization.  Refer to MATLAB's optimset function for information
% about these options.
%
% See also CloudFitXY
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function result=analyze(object,curve,guess,bound,evaluation,varargin)

% handle input
assert(nargin>=3,'ERROR: insufficient input');

if ischar(curve)
    curve=str2func(curve);
end
assert(isa(curve,'function_handle'),'ERROR: invalid curve function');
curve=struct('Function',curve);
assert(isnumeric(guess),'ERROR: invalid guess array');
Nparam=numel(guess);
guess=reshape(guess,[1 Nparam]);

if (nargin<4) || isempty(bound)
    bound(1,1:Nparam)=-inf;
    bound(2,1:Nparam)=+inf;
end
assert(all(size(bound)==[2 Nparam]),'ERROR: invalid bound array');

if (nargin<5) || isempty(evaluation) || strcmpi(evaluation,'auto');
    evaluation=[];
end
assert(isnumeric(evaluation),'ERROR: invalid evaluation array');

options=optimset(varargin{:});

% extract cloud data
clouds=getActiveClouds(object);
M=numel(clouds);
N=object.CloudSize;
[X,Y]=deal(nan(M,N));
for k=1:M
    temp=clouds{k}.Data(:,1);
    X(k,:)=reshape(temp,[1 object.CloudSize]);
    temp=clouds{k}.Data(:,2);
    Y(k,:)=reshape(temp,[1 object.CloudSize]);
end

% normalize clouds
xb=[+inf -inf];
yb=[+inf -inf];
for m=1:M
    temp=clouds{m}.Moments;
    xm=temp(1,1);
    xb(1)=min(xb(1),xm);
    xb(2)=max(xb(2),xm);
    ym=temp(2,1);
    yb(1)=min(yb(1),ym);
    yb(2)=max(yb(2),ym);
end

x0=xb(1);
Lx=xb(2)-xb(1);
y0=yb(1);
Ly=yb(2)-yb(1);

Xnorm=(X-x0)/Lx;
Ynorm=(Y-y0)/Ly;

% prepare curves for normalization
if isempty(evaluation)
    evaluation=linspace(xb(1),xb(2),100);
elseif SMASH.General.testNumber(evaluation,'integer')
    evaluation=linspace(xb(1),xb(2),evaluation);
end

curve.x0=x0;
curve.y0=y0;
curve.Lx=Lx;
curve.Ly=Ly;

% % calculate survival array
% S=nan(size(X));
% for m=1:m
%     L2=(Xnorm(m,:)-mean(Xnorm(m,:))).^2+(Ynorm(m,:)-mean(Ynorm(m,:))).^2;
%     S(m,1)=feval(object.WeightFunction,L2(:));
% end
% S(:,1)=min(S(:,1))./S(:,1);
% S=repmat(S(:,1),[1 N]);

% calculate weights and allowed directions
[weights,allowed]=deal(nan(size(X)));
for m=1:M
    
end


% perform iteration, in parallel if possible
meanXnorm=mean(Xnorm,2);
meanYnorm=mean(Ynorm,2);
Nguess=numel(guess);
result=nan(object.Iterations,Nguess);
%parfor iteration=1:object.Iterations
for iteration=1:object.Iterations
    % randomly shift clouds
    index=randi(N,[M 1]);
    index=sub2ind([M N],transpose(1:M),index);
    P=Xnorm(index)-meanXnorm;
    P=repmat(P,[1 N]);
    Q=Ynorm(index)-meanYnorm;
    Q=repmat(Q,[1 N]);
    % apply survival criterea
    H=rand(M,N);
    H=(H<=S);
    % minimize mean square orthogonal distance
    param=fminsearch(...
        @(p) residual(p,curve,bound,evaluation,Xnorm+P,Ynorm+Q,H),...
        guess,options);
    %param=optimize(curve,evaluation,Xnorm+P,Ynorm+Q,H,guess,options);
    % store parameter
    result(iteration,:)=reshape(param,[1 Nguess]);
end

result=SMASH.MonteCarlo.Cloud(result,'table');
label=cell(1,result.NumberVariables);
for k=1:result.NumberVariables
    label{k}=sprintf('Parameter #%d',k);
end
result.DataLabel=label;

end

function meanL2=residual(param,curve,bound,evaluation,Xnorm,Ynorm,H)

if any(param<bound(1,:)) || any(param>bound(2,:))
    meanL2=inf;
    return;
end

[x,y]=feval(curve.Function,param,evaluation);

x=(x-curve.x0)/curve.Lx;
y=(y-curve.y0)/curve.Ly;

Xnorm=Xnorm(H);
Ynorm=Ynorm(H);

%[L2,nearest]=points2curve([Xnorm(:) Ynorm(:)],[x(:) y(:)]);
[~,L2]=distance2curve([x(:) y(:)],[Xnorm(:) Ynorm(:)]);
%L2=interp1(x,y,Xnorm);
%L2=(L2-Ynorm).^2;
meanL2=mean(L2);

end
