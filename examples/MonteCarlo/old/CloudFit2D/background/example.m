function example(mode)

% handle input
if (nargin<1) || isempty(mode)
    mode='A';
end

% data points
tic;
x=[0 0.5 1];
switch mode
    case 'A'
        y=[0 0.5 0.9];
        dy=repmat(0.1,size(y));
    case 'B'
        y=[0 0.5 0.2];
        dy=[0.1 0.1 1];
    case 'C'
        y=[0 0.5 0.2];
        dy=[0.1 0.1 0.5];
end
clc
fprintf('Using data set: %s\n\n',mode);

plot(x,y,'ko');
hold on;
errorbar(x,y,dy,'LineStyle','none','Color','k');
hold off;
xlabel('x');
ylabel('y');
figure(gcf);

% weighted least squares fit
[fit,param,Dparam]=WeightedLineFit(x,y,dy);
h(1)=line(x,fit,'Color','b');
summarize(param,Dparam,'Weighted least squares');

% basic Monte-Carlo
iterations=1000;
X=repmat(x,[iterations 1]);
Y=repmat(y,[iterations 1]);
DY=repmat(dy,[iterations 1]);
DY=DY.*randn(size(DY));
Y=Y+DY;
param=nan(iterations,2);
parfor k=1:iterations
    param(k,:)=polyfit(X(k,:),Y(k,:),1);
end
Dparam=std(param,1,1);
param=mean(param,1);
fit=polyval(param,x);
h(2)=line(x,fit,'Color','g');
summarize(param,Dparam,'Basic Monte Carlo');

% basic clouds
cloudsize=500;
param=nan(iterations,2);
parfor k=1:iterations
    X=repmat(x,[cloudsize 1]);
    Y=repmat(y,[cloudsize 1]);
    DY=repmat(dy,[cloudsize 1]);
    DY=DY.*randn(size(DY));
    Y=Y+DY;
    param(k,:)=polyfit(X(:),Y(:),1);
end
Dparam=std(param,1,1);
param=mean(param,1);
fit=polyval(param,x);
h(3)=line(x,fit,'Color','r');
summarize(param,Dparam,'Basic cloud fit');

% weighted clouds #1 (drop method)
keep=round(cloudsize*(min(dy)./dy).^2);
param=nan(iterations,2);
parfor k=1:iterations
    X=repmat(x,[cloudsize 1]);
    Y=repmat(y,[cloudsize 1]);
    DY=repmat(dy,[cloudsize 1]);
    DY=DY.*randn(size(DY));
    Y=Y+DY;
    for m=1:numel(keep);
        Y(keep(m):end,m)=nan;
    end
    X=X(:);
    Y=Y(:);
    index=~isnan(Y);
    X=X(index);
    Y=Y(index);
    param(k,:)=polyfit(X,Y,1);
end
Dparam=std(param,1,1);
param=mean(param,1);
fit=polyval(param,x);
h(4)=line(x,fit,'Color','m');
summarize(param,Dparam,'Weighted cloud fit #1 (drop)');

% % weighted clouds #2
% weight=1./dy.^2;
% W=repmat(weight,[cloudsize 1]);
% param=nan(iterations,2);
% parfor k=1:iterations
%     X=repmat(x,[cloudsize 1]);
%     Y=repmat(y,[cloudsize 1]);
%     DY=repmat(dy,[cloudsize 1]);    
%     DY=DY.*randn(size(DY));
%     Y=Y+DY;
%     Q=nan(numel(X),2);
%     Q(:,1)=X(:).*W(:);    
%     Q(:,2)=W(:);
%     Y=Y(:).*W(:);
%     beta=Q\Y;
%     param(k,:)=transpose(beta);
% end
% Dparam=std(param,1,1);
% param=mean(param,1);
% fit=polyval(param,x);
% h(5)=line(x,fit,'Color','c');
% summarize(param,Dparam,'Weighted cloud fit #2 (keep)');

% weighted clouds #2 (shift + drop)
keep=round(cloudsize*(min(dy)./dy).^2);
param=nan(iterations,2);
parfor k=1:iterations
    X=repmat(x,[cloudsize 1]);
    Y=repmat(y,[cloudsize 1]);    
    DY=repmat(dy,[cloudsize 1]);
    DY=DY.*randn(size(DY));
    Y=Y+DY;
    shift=dy.*randn(size(dy));    
    Y=Y+repmat(shift,[cloudsize 1]);
    for m=1:numel(keep);
        Y(keep(m):end,m)=nan;
    end
    X=X(:);
    Y=Y(:);
    index=~isnan(Y);
    X=X(index);
    Y=Y(index);
    param(k,:)=polyfit(X,Y,1);
end
Dparam=std(param,1,1);
param=mean(param,1);
fit=polyval(param,x);
h(5)=line(x,fit,'Color','c');
summarize(param,Dparam,'Weighted cloud fit #2 (shift + drop)');


% generate legend
legend(h,'Weighted least square','Basic Monte Carlo',...
    'Basic cloud','Weighted cloud #1',...
    'Weighted cloud #2 ',...
    'Location','northwest');

toc
end

function summarize(param,Dparam,label)
fprintf('%s\n',label);
fprintf('\t parameters =%+5.3f %+5.3f\n',param);
fprintf('\t uncertainty=%+5.3f %+5.3f\n',Dparam);

end