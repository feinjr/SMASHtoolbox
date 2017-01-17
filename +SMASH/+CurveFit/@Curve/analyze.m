% analyze Analyze fit uncertainty
%
% report=analyze(object,data,iterations,cutoff);

function [report,accept]=analyze(object,data,iterations,cutoff)

assert(object.FitComplete,...
    'ERROR: fit must be performed before uncertainty analysis');

% manage input
assert(nargin >= 2,'ERROR: no data specified');
assert(isnumeric(data),'ERROR: data table must be numeric');
if size(data,2)==2
    err=data(:,2)-evaluate(object,data(:,1));
    err=sqrt(mean(err.^2));
    data(:,3)=err;   
end
assert(size(data,2)==3,'ERROR: data table must have 2-3 columns');
assert(all(data(:,3) > 0),'ERROR: invalid uncertainty value(s)');
x=data(:,1);
y=data(:,2);
Dy=data(:,3);

if (nargin<3) || isempty(iterations)
    iterations=1000;
end 
assert(...
    SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
    'ERROR: invalid interations value');

if (nargin<4) || isempty(cutoff)
    cutoff=0.10;
    %cutoff=0.01;
end

% prepare parameter arrays
Nbasis=numel(object.Basis);
start=nan(1,Nbasis);
stop=nan(1,Nbasis);
full=[];

for m=1:Nbasis
    if m==1
        start(m)=1;
    else
        start(m)=stop(m-1)+1;
    end
    param=object.Parameter{m};
    Nparam=numel(param);
    stop(m)=start(m)+Nparam-1;    
    full=[full param]; %#ok<AGROW>
end

for m=1:Nbasis
    full(end+1)=object.Scale{m}; %#ok<AGROW>
end
Nfull=numel(full);

% perform analysis
    function chi2=residual(local)
        % parameter conversion
        for j=1:Nbasis
            object.Parameter{j}=local(start(j):stop(j));
            object.Scale{j}=local(end-Nbasis+j);
        end
        fit=evaluate(object,x);   
        % residual calculation with complex values and weight support
        chi2=y-fit;
        chi2=real(chi2.*conj(chi2));
        chi2=sum(chi2./Dy.^2);
    end

 function [err,value]=scan(index,direction,value)
        local=full;
        value=local(index)+direction*value^2;
        local(index)=value;
        chi2=residual(local);        
        err=exp((chi2min-chi2)/2)-cutoff;
    end    

chi2min=residual(full);
fullWidth=nan(size(full));
for m=1:Nfull
    q=fzero(@(x) scan(m,+1,x),0);
    [~,fullUpper]=scan(m,+1,q);
    q=fzero(@(x) scan(m,-1,x),0);
    [~,fullLower]=scan(m,-1,q);
    fullWidth(m)=(fullUpper-fullLower)/2;
end

draw=rand(iterations,1);
table=nan(iterations,Nfull);
table(1,:)=full;
previous=chi2min;
accept=0;
for k=2:iterations % Markov chain analysis
    temp=table(k-1,:)+fullWidth.*randn(1,Nfull);    
    chi2=residual(temp);
    Prelative=exp((previous-chi2)/2);
    if Prelative >= draw(k)
        table(k,:)=temp;
        previous=chi2;
        accept=accept+1;
    else
        table(k,:)=table(k-1,:);
    end
end
accept=accept/iterations;  

% manage output
report=SMASH.MonteCarlo.Cloud(table,'table');
label=report.VariableName;
k=0;
for m=1:Nbasis
    for n=1:numel(object.Parameter{m})
        k=k+1;
        label{k}=sprintf('Basis %d Parameter %d',m,n);
    end
    label{end-Nbasis+m}=sprintf('Basis %d Scale factor',m);
end
report=configure(report,'VariableName',label);

end