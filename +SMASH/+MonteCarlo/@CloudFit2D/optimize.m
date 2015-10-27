% UNDER CONSTRUCTION



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
function result=optimize(object,options,parallel)

% manage input
if (nargin<2) || isempty(options)
    options=optimset();
end
data.Options=options;

if (nargin<3) || isempty(parallel)
    parallel=false;
elseif strcmpi(parallel,'parallel')
    parallel=true;
else
    parallel=false;
end

% make sure object is ready for optimization
if isempty(object.Function)
    error('ERROR: no fit function specified');
end
data.Function=object.Function;
data.Bounds=object.Bounds;

% extract cloud data
clouds=getActiveClouds(object);
data.NumberClouds=numel(clouds);
data.CloudSize=object.CloudSize;
[X,Y]=deal(nan(data.NumberClouds,data.CloudSize));
for k=1:data.NumberClouds
    temp=clouds{k}.Data(:,1);
    X(k,:)=reshape(temp,[1 data.CloudSize]);
    temp=clouds{k}.Data(:,2);
    Y(k,:)=reshape(temp,[1 data.CloudSize]);
end

% normalize clouds
temp=mean(X,2);
xmin=min(temp);
xmax=max(temp);
data.x0=xmin;
data.Lx=xmax-xmin;

temp=mean(Y,2);
ymin=min(temp);
ymax=max(temp);
data.y0=ymin;
data.Ly=ymax-ymin;

data.X=(X-data.x0)/data.Lx;
data.Y=(Y-data.y0)/data.Ly;
data.meanX=mean(data.X,2);
data.meanY=mean(data.Y,2);

% calculate weights and allowed directions
data.Weights=nan(size(X));
data.Allowed=nan(size(X));
for m=1:M
    DX=data.X(m,:)-mean(data.X(m,:));
    DY=data.Y(m,:)-mean(data.Y(m,:));
    L2=DX.^2+DY.^2;
    data.Weights(m,:)=feval(object.WeightFunction,L2);   
    data.Allowed(m,:)=atan2(DY,DX);
end

% perform iterations
Nparam=numel(object.Parameter);
result=nan(object.Iterations,Nparam);
if parallel
    parfor iteration=1:object.Iterations
        param=fitCloud(data);
        result(iteration,:)=param;
    end
else
    for iteration=1:object.Iterations
        param=fitCloud(data);
        result(iteration,:)=param;
    end
end

result=SMASH.MonteCarlo.Cloud(result,'table');
label=cell(1,result.NumberVariables);
for k=1:result.NumberVariables
    label{k}=sprintf('Parameter #%d',k);
end
result.DataLabel=label;

end

function param=fitCloud(data)

% randomly shift clouds
index=randi(data.CloudSize,[data.NumberClouds 1]);
index=sub2ind([data.NumberClouds data.CloudSize],...
    transpose(1:data.NumberClouds),index);

X=data.X(index)-data.meanX;
X=repmat(X,[1 object.NumberClouds]);
X=data.X+X;

Y=data.Y(index)-data.meanY;
Y=repmat(Y,[1 object.NumberClouds]);
Y=data.Y+Y;

theta=data.Allowed;

% minimize weighted residual along allowed directions

L2=inf(data.NumberClouds,data.CloudSize);
    function meanL2=residual(param)
        % generate curve segments
        [p,q]=feval(data.Function,param);
        u=p(2:end);
        v=q(2:end);
        p=p(1:end-1);
        q=q(1:end-1);
        keep = ~ (isnan(p) & isnan(q) & isnan(u) & isnan(v));
        p=p(keep);
        q=q(keep);
        u=u(keep);
        v=v(keep);
        % find nearest allowed distance for each segment      
        L2min=inf;
        for k=1:numel(p)            
            L2(:)=inf;
            D=(u-p)*sin(theta)-(v-q).*cos(theta); % denominator
            gamma=(X-p).*sin(theta)-(Y-q).*cos(theta);            
            gamma=gamma./D;
            valid=(gamma>=0) & (gamma<=1);
            D=(v-q).*cos(theta(valid))-(u-p).*sin(theta(valid)); % denominator
            L2(valid)=(p-X(valid)).*(v-q)-(q-Y(valid)).*(u-p);
            L2(valid)=L2(valid)./D;
            
        end
        % calculated weighted mean distance
        
    end
param=fminsearch(@residual,data.Parameters,data.Options);


%     % store parameter
%     result(iteration,:)=reshape(param,[1 Nguess]);

end


function meanL2=residual_old(param,curve,bound,evaluation,Xnorm,Ynorm,H)

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
