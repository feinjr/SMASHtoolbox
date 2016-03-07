function [result,miss]=analyze(object,iterations,silent)

% manage input
if (nargin<2) || isempty(iterations)
    iterations=100;
end

if (nargin<3) || isempty(silent) || strcmpi(silent,'verbose')
    silent=false;
elseif strcmpi(silent,'silent')
    silent=true;
else
    error('ERROR: invalid silent input');
end

% Monte Carlo simulations  
if object.AssumeNormal
    mode='normal';
else
    mode='general';
end

miss=nan(object.NumberMeasurements,iterations);
result=nan(numel(object.Parameter),iterations);
if SMASH.System.isParallel
    parfor k=1:iterations
        [temp1,temp2]=process(object,mode);
        result(:,k)=temp1(:);
        miss(:,k)=temp2(:);
    end
else
    for k=1:iterations
        [temp1,temp2]=process(object,mode);
        result(:,k)=temp1(:);
        miss(:,k)=temp2(:);
    end
end

% report missed points
if ~silent && any(miss(:))
    message={};
    message{end+1}='Some measurements were missed during optimization';
    message{end+1}='Parameter results may need to trimmed';
    warning('SMASH:Curvefit2D','%s\n',message{:});
end

% generate results
result=transpose(result);
result=SMASH.MonteCarlo.Cloud(result,'table');
name=result.VariableName;
for p=1:result.NumberVariables
    name{p}=sprintf('Parameter %d',p);
end
result=configure(result,'VariableName',name);

end

function [parameter,miss]=process(object,mode)

object=recenter(object,mode);
[object,miss]=optimize(object,[],'silent');
parameter=object.Parameter;

end