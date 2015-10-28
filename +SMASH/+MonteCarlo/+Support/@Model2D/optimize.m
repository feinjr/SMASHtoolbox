function object=optimize(object,data,weight,covariance,group)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
[Npoints,Ncol]=size(data);
assert(Ncol==2,'ERROR: data table must have two columns');

if (nargin<3) || isempty(weight)
    weight=ones(Npoints,1);
end

if (nargin<4) || isempty(covariance)
    covariance=[1 1 0]; % var(x) var(y) var(xy)
end

if (nargin<5) || isempty(group)
    M=size(covariance,1);
    if M==1
        group=[1 Npoints];
    elseif M==Npoints
        group=repmat(transpose(1:Npoints),[1 2]);
    end
end
assert((size(group,2)==2) && all(group(:,2)>=group(:,1)),...
    'ERROR: invalid group array');
%valid=1:Npoints;
% additional group testing

% normalize weight
weight=weight/sum(weight);

% perform optimization
L=size(group,1);
matrix=nan(2,2);
    function chi2=residual(p)
        chi2=0;
        for k=1:L
            matrix(1,1)=covariance(k,1);
            matrix(1,2)=covariance(k,3);
            matrix(2,1)=covariance(k,3);
            matrix(2,2)=covariance(k,2);           
            index=group(k,1):group(k,2);
            object=evaluate(object,p);
            D2=calculateDistance(object.Curve,data(index,:),matrix);
            chi2=chi2+sum(D2.*weight(index));
        end
    end

result=fminsearch(@residual,object.SlackVariables,...
    object.OptimizationSettings);
for m=1:object.NumberParameters
    object=setParameter(object,m,result(m));
end

end