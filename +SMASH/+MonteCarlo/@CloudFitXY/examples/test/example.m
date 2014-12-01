%% example A
x=[0 0.5 1];
y=[0 0.5 0.5];
%dy=[0.1 0.1 0.2];
%dy=[0.1 0.1 0.4];
dy=repmat(0.1,size(x));

Ncloud=1000;
xcloud=repmat(x,[Ncloud 1]);
dyc=repmat(dy,[Ncloud 1]).*randn(size(xcloud));
ycloud=repmat(y,[Ncloud 1])+dyc;

w=1./std(ycloud,[],1).^2;
w=repmat(w,[Nreduced 1]);

Nreduced=100;
xcloud=xcloud(1:Nreduced,:);
ycloud=ycloud(1:Nreduced,:);
w=w(1:Nreduced,:);

M=1000;
param=nan(M,2);
for m=1:M
    index=randi(Ncloud,1);
    temp=repmat(dyc(index,:),[Nreduced 1]);
    param(m,:)=linefit(xcloud,ycloud+temp,w);
end

plot(param(:,1),param(:,2),'.');
%L=Ncloud*numel(x);
L=1;
Dparam=std(param,[],1)*sqrt(L); % convert std of mean to std of population
param0=mean(param,1);

 [~,p,Dp]=WeightedLineFit(x,y,dy);
 
 clc
 param0,p
 Dparam,Dp