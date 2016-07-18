% analyze Analyze parameter variation

function [result,accept]=analyze(object,iterations,drop)

% manage input
assert(object.Optimized,'ERROR: model parameters must be optimized before this analysis can be performed');

if (nargin<2) || isempty(iterations)
    iterations=10e3;
end

if (nargin<3) || isempty(drop)
    drop=round(0.10*iterations);    
end

% estimate parameter range
origin=object.Parameter;
goal=examine(object,origin)*exp(-1/2);

Nparam=numel(object.Parameter);
width=nan(Nparam,1);
for n=1:Nparam
    xp=fzero(@(x) moveUp(n,x),0);
    xp=origin(n)+xp^2;
    xn=fzero(@(x) moveDown(n,x),0);
    xn=origin(n)-xn^2;
    width(n)=(xp-xn)/2;
end
    function err=moveUp(index,value)
        local=origin;
        local(index)=local(index)+value^2;
        err=examine(object,local);
        err=err-goal;
    end
    function err=moveDown(index,value)
        local=origin;
        local(index)=local(index)-value^2;
        err=examine(object,local);
        err=err-goal;
    end

% prepare random draws
moments(:,1)=origin(:);
moments(:,2)=width(:).^2;
source=SMASH.MonteCarlo.Cloud(moments,[],iterations);

draw=rand(iterations,1);

% Metropolis sampling
accept=0;
result=nan(iterations,Nparam);
result(1,:)=source.Data(1,:);
old=examine(object,result(1,:));
for n=2:iterations
    result(n,:)=source.Data(n,:);
    new=examine(object,result(n,:));
    temp=exp(new-old);
    if temp >= draw(n);
        old=new;
        accept=accept+1;
    else
        result(n,:)=result(n-1,:);
    end
end

result=result(drop:end,:);
result=SMASH.MonteCarlo.Cloud(result,'table');

accept=accept/iterations;

end