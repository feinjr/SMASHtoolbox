% analyze Analyze parameter uncertainty
%
% This method analyzes parameter uncertainty for a Curve object.
%    report=analyze(object,data,iterations);
% The input "data" must be a 2-3 column ([x y] or [x y dy]) column of
% data points.  The input "interations" is optional (default value is 1000)
% and can be any positive integer.  Larger iteration numbers take more time
% but produce more reliable results.
%
% The output "report" is a Cloud object describing the variation in all
% basis parameters and scale factors.  NOTE: this method cannot be used
% until the fit method has been called.  Adding, removing, and editing the
% basis functions in a Curve object require the fit method to be called
% before uncertainty analysis.
%
% See also SMASH.CurveFit, fit, SMASH.MonteCarlo.Cloud
%

%
% created January 17, 2016 by Daniel Dolan (Sandia National Laboratories)
%
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
weight=1./Dy.^2;

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

% estimate parameter variation
    function err=scan(index,direction,value)        
        %fprintf('%g\n',value)
        local=full;
        local(index)=local(index)+direction*abs(value);
        try
            chi2=residual(local);
            assert(isfinite(chi2) && isreal(chi2));
            err=exp(-abs(chi2-chi2min)/2)-cutoff;
        catch
            err=-(1-cutoff)*(1+abs(value)); % penalty function
        end 
        %err=abs(err);
    end    
   
chi2min=residual(full);
fullWidth=nan(size(full));
for m=1:Nfull
    guess=std(object.FitTable(m,:));
    if guess == 0
        fullWidth(m)=fzero(@(x) scan(m,+1,x),0);
    else
        left=guess;
        while true
            if scan(m,+1,left) > 0
                break
            else
                left=left/2;
            end
        end
        right=guess;
        while true
            if scan(m,+1,right) < 0
                break
            else
                right=2*right;
            end
        end
        width1=fzero(@(x) scan(m,+1,x),[left right]);
        width2=fzero(@(x) scan(m,-1,x),[left right]);
        fullWidth(m)=(width1+width2)/2;
    end    
end

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
        chi2=weight.*real(chi2.*conj(chi2));
        plot(x,chi2);
        chi2=sum(chi2);
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