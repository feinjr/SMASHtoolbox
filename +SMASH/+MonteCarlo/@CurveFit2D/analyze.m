% analyze Analyze parameter variation

function [result,accept]=analyze(object,iterations,varargin)

% function object=set.Metropolis(object,value)
%             assert(isstruct(value),'ERROR: invalid Metropolis settings');
%             name=fieldnames(value);
%             for n=1:numel(name)
%                 switch name{n}
%                     case 'Burn'
%                         
%                     case 'Lag'
%                         
%                     case 'Scale'
%                         
%                     otherwise
%                         error('ERROR: invalid Metropolis setting');
%                 end
%             end
%             object.Metropolis=value;
%         end
% 
% manage input
assert(object.Optimized,...
    'ERROR: model parameters must be optimized before this analysis can be performed');

if (nargin<2) || isempty(iterations)
    iterations=2*object.Metropolis.Burn;
end
assert(SMASH.General.testNumber(iterations,'integer','positive'),...
    'ERROR: invalid number of iterations');
assert(iterations >= 2*object.Metropolis.Burn,'ERROR: more iterations needed to overcome the burn-in phase');

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
moments(:,2)=(scale*width(:)).^2;
source=SMASH.MonteCarlo.Cloud(moments,[],iterations);

draw=rand(iterations,1);

% evaluate likelihoods
likelihood=nan(iterations,1);
if SMASH.System.isParallel
    parfor n=1:iterations
        likelihood(n)=examine(object,source.Data(n,:));
    end
else
    for n=1:iterations
        likelihood(n)=examine(object,source.Data(n,:));
    end    
end

% Metropolis sampling
accept=0;
result=nan(iterations,Nparam);
result(1,:)=source.Data(1,:);
old=likelihood(1);
for n=2:iterations
    result(n,:)=source.Data(n,:);
    new=likelihood(n);
    temp=exp(new-old);
    if temp >= draw(n);
        old=new;
        accept=accept+1;
    else
        result(n,:)=result(n-1,:);
    end
end

result=result(drop:skip:end,:);
result=SMASH.MonteCarlo.Cloud(result,'table');

accept=accept/iterations;

end