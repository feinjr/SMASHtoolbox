% ellipse Generate bounding ellipse (possibly distorted)
% 
% This method estimates a 2D bounding ellipse containing the fraction of
% cloud points defind by the EllipseSpan property.
%    >> [x,y]=ellipse(object);
% If the Cloud spans three or more dimensions, the user is prompted to
% select two variables for the ellipse; variables can also be specified
% directly.
%    >> [x,y]=ellipse(object,[1 3]); % select first and third variable
%
% The bounding ellipse may be distorted if the cloud variables have a
% non-normal distribution; these distortions indicate skewness and/or
% excess kurtosis. Distorted ellipses are only generated if the object's
% EllipseDistortion property is true (the default value is false).
%
% Bounding curves may be poorly defined if there are too few cloud points
% (<1000).  Ellipse calculations may be slow for very large clouds (>1
% million points), though not unbearable except for distorted calculations
% on highly non-normal distributions (which may not converge).  Large span
% fractions (e.g., >0.99) may be ill defined if there are signifiant gaps
% in the outmost cloud points.  Recommend values for the ellipse span are
% 0.50-0.95.
%
% See also Cloud, hist, view
%

% created July 23, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised August 5, 2014 by Daniel Dolan
%    -Fixed a matrix transpose bug
%    -Modified input handling
% revised October 29, 2015 by Daniel Dolan
%    -Implemented faster refinement of the ellipse boundary
%    -Added an input for refinement options (currently undocumented)
%    -Ellipse span input removed (using object property instead)
%    -Enabled undistorted ellipse capability (on by default)
function varargout=ellipse(object,variable,options)

% handle input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'match');
end
assert(numel(variable)==2 & ...
    SMASH.General.testNumber(variable(1),'positive','integer') & ...
    SMASH.General.testNumber(variable(2),'positive','integer') & ...
    all(variable>0) & all(variable<=object.NumberVariables),...
    'ERROR: invalid variable selection');

default=struct('Iterations',100,'Tolerance',1e-4);
if (nargin<4) || isempty(options)
    options=default;
end
name=fieldnames(default);
for k=1:numel(name)
    if ~isfield(options,name{k})
        options.(name{k})=default.(name{k});
    end
end

% extract data
span=object.EllipseSpan;

moment=object.Moments(variable,:);
if ~object.EllipseDistortion
    moment(:,3:4)=0;
end
correlation=object.Correlations(variable(1),variable(2));
correlation=[1 correlation; correlation 1];

% generate and refine ellipse
origin=transpose(moment(:,1));
M=size(object.Data,1); % number of cloud points
vector=bsxfun(@minus,object.Data,origin);
ratio=zeros(M,1);

N=100; % number of ellipse points
eta=1;
boundary=round(span*M); % boundary index
for iteration=1:options.Iterations
    [x,y]=pdomain(moment,correlation,eta,N);
    temp=bsxfun(@minus,[x(:) y(:)],origin);
    u=temp(1:end-1,:);
    v=temp(2:end,:);
    w=(u+v)/2;
    L2ellipse=w(:,1).^2+w(:,2).^2;
    for n=1:(N-1)
        test1=vector(:,1)*w(n,1)+vector(:,2)*w(n,2); % dot product
        test2=(vector(:,1)*u(n,2)-vector(:,2)*u(n,1))...
            .*(vector(:,1)*v(n,2)-vector(:,2)*v(n,1)); % cross product
        index=(test1>0) & (test2<=0);
        L2point=vector(index,1).^2+vector(index,2).^2;      
        ratio(index)=L2point/L2ellipse(n);
    end
    ratio=sort(sqrt(ratio));    
    correction=ratio(boundary);
    %fprintf('%10d: %10.4f %10.4f\n',iteration,eta,correction);
    eta=eta*correction;
    if abs(correction-1)<options.Tolerance
        break
    end
end
if iteration==options.Iterations
    warning('SMASH:Cloud','Ellipse refinement did not converge');
end
[x,y]=pdomain(moment,correlation,eta,N);

% handle output
if nargout==0
    figure;
    plot(x,y);
else    
    varargout{1}=x(:);   
    varargout{2}=y(:);   
    varargout{3}=span;
end

end