function object=fit(object,data,options)

% handle input
assert(nargin>=2,'ERROR: insufficient input');

assert(isnumeric(data),'ERROR: data table must be numeric');
Ncolumn=size(data,2);
if Ncolumn==2
    data(:,3)=1;
    Ncolumn=3;
end
assert(Ncolumn==3,'ERROR: data table must have 2-3 columns');

if (nargin<3) || isempty(options)
    options=optimset();
end

% prepare parameter arrays
Nbasis=numel(object.Basis);
start=nan(1,Nbasis);
stop=nan(1,Nbasis);
guess=[];
lower=[];
upper=[];

for m=1:Nbasis
    if m==1
        start(m)=1;
    else
        start(m)=stop(m-1)+1;
    end
    param=object.Parameter{m};
    assert(~any(isinf(param)),'ERROR: infinite parameter detected');
    assert(~any(isnan(param)),'ERROR: nan parameter detected');
    Nparam=numel(param);
    stop(m)=start(m)+Nparam-1;
    for n=1:Nparam
        lower(end+1)=object.Bound{m}(1,n); %#ok<AGROW>
        upper(end+1)=object.Bound{m}(2,n); %#ok<AGROW>
        if param(n)<lower(end)
            param(n)=lower(end);
            warning('SMASH:CurveFit',...
                'Invalid parameter detected, using lower bound instead');
        elseif param(n)>upper(end)
            param(n)=upper(end);
            warning('SMASH:CurveFit',...
                'Invalid parameter detected, using upper bound instead');
        end
        guess(end+1)=bound2free(param(n),lower(end),upper(end)); %#ok<AGROW>                
    end    
end
Ntotal=numel(guess);

% perform optimization
x=data(:,1);
y=data(:,2);
weight=data(:,3);
weight=weight./sum(weight);

fixed=false(1,Nbasis);
for m=1:Nbasis
    if object.FixScale{m}
        fixed(m)=true;
    end
end

    function [chi2,scale]=residual(current)       
        % parameter conversion and penalty assessment
        penalty=ones(1,Ntotal);
        for j=1:Ntotal
            if isinf(lower(j)) || isinf(upper(j)) || lower(j)==upper(j)
                % do nothing
            elseif abs(current(j))>1
                penalty(j)=abs(current(j));
            end
            current(j)=free2bound(current(j),lower(j),upper(j));            
        end      
        scale=nan(Nbasis,1);
        for j=1:Nbasis
            object.Parameter{j}=current(start(j):stop(j));
            scale(j)=object.Scale{j};
        end
        [~,basis]=evaluate(object,x);
        % reduced basis
        y_fixed=sum(basis(:,fixed),2);
        y_reduced=y-y_fixed;
        basis_reduced=basis(:,~fixed);
        scale_reduced=distinctLLS(basis_reduced,y_reduced);
        fit_reduced=basis_reduced*scale_reduced;
        fit=fit_reduced+y_fixed;   
        scale(~fixed)=scale_reduced;
        % residual calculation 
        chi2=y-fit; % what about complex values?
        chi2=mean(weight.*chi2.^2);
        chi2=chi2*prod(penalty);
    end
param=fminsearch(@residual,guess,options);

[chi2,scale]=residual(param);
fprintf('chi2=%g\n',chi2);
for m=1:Ntotal
    param(m)=free2bound(param(m),lower(m),upper(m));
end

for m=1:Nbasis
    object.Parameter{m}=param(start(m):stop(m));
    object.Scale{m}=scale(m);
end

end
