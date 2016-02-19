% UNDER CONSTRUCTION
%

%
%
%
function varargout=bound(object,variable)

% manage input
if (nargin<2) || isempty(variable)
    variable=selectVariables(object,2,'bound');
end
assert(numel(variable)<=2,'ERROR: too many variables');
valid=1:object.NumberVariables;
for k=1:numel(variable)
    assert(any(variable(k)==valid),'ERROR: invalid variable number');
end

% create new object for selected variables
new=SMASH.MonteCarlo.Cloud(object.Data(:,variable),'table');
new.VariableName=object.VariableName(variable);
new.GridPoints=object.GridPoints(variable);
new.SmoothFactor=object.SmoothFactor;
new.NumberContours=object.NumberContours;
new.BoundLevel=object.BoundLevel;

% locate boundaries
switch new.NumberVariables
    case 1
        result=calculateBound1(new);
    case 2
        result=calculateBoudn2(new);
end

% manage output
varargout{1}=result;

end

% function table=calculateBound1(obj)
% 
% [dgrid,dvalue]=density(obj);
% 
% x=[1 2];
% z=repmat(dvalue,[1 2]);
% 
% N=numel(obj.BoundLevel);
% table=nan(N,2);
% fraction=[];
%     function err=residual(level)
%         fraction=zeros(size(obj.BoundLevel));
%         matrix=contourc(x,dgrid,z,level);
%         % determine coverage
%         while ~isempty(matrix)
%             n=find(matrix(1,1)==level);                        
%             next=matrix(2,1)+2;
%             table(n,1)=matrix(2,2);
%             matrix=matrix(:,next:end);
%             table(n,2)=matrix(2,2);
%             matrix=matrix(:,next:end);
%             table(n,:)=sort(table(n,:));
%             % determine coverage
%             temp=(obj.Data>=table(n,1)) & (obj.Data<=table(n,2));
%             fraction(n)=sum(temp)/obj.NumberPoints;
%         end
%         % calculate error
%         err=sum((fraction-goal).^2);
%     end
% 
% goal=obj.BoundLevel;
% guess=(1-goal)*max(dvalue);
% if isscalar(guess)
%     guess=repmat(guess,[1 2]);
% end
% result=fminsearch(@residual,guess);
% 
% end

function table=calculateBound1(obj)

[dgrid,dvalue]=density(obj);
x=[1 2];
z=repmat(dvalue,[1 2]);



end

function result=calculateBound2(obj)

end