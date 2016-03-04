function result=analyze(object,iterations)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end

% Monte Carlo simulations  
if object.AssumeNormal
    mode='normal';
else
    mode='general';
end

result=nan(numel(object.Parameter),iterations);
if SMASH.System.isParallel
    parfor k=1:iterations
        temp=process(object,mode);
        result(:,k)=temp(:);
    end
else
    for k=1:iterations
        temp=process(object,mode);
        result(:,k)=temp(:);
    end
end

% generate results
result=transpose(result);
result=SMASH.MonteCarlo.Cloud(result,'table');

end

function parameter=process(object,mode)

object=recenter(object,mode);
object=optimize(object);
parameter=object.Parameter;

end