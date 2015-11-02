% UNDER CONSTRUCTION
function [points,weights,covariance,group]=drawPoints(object)

% extract active clouds
clouds=object.CloudData(object.ActiveClouds);
N=numel(clouds);

% manage draws
draw=repmat(object.NumberDraws,[N 1]);
% economy mode?

weights=object.CloudWeights;
covariance=nan(N,3);
group=nan(N,2);

% perform draws
shift=nan(1,2);
points=nan(sum(draw),2);
start=1;
for n=1:N
    L=clouds{n}.NumberPoints;
    index=randi([1 L],[draw(n) 1]);
    stop=start-1+draw(n);
    points(start:stop,:)=clouds{n}.Data(index,:);
    if object.Recenter % recenter draw points
        index0=randi([1 L],1);
        shift(1)=clouds{n}.Data(index0,1)-clouds{n}.Moments(1,1);
        shift(2)=clouds{n}.Data(index0,2)-clouds{n}.Moments(2,1);
        points=bsxfun(@plus,points,shift);
    end
    sigmax2=clouds{n}.Moments(1,2);
    sigmay2=clouds{n}.Moments(2,2);
    sigmaxy=clouds{n}.Correlations(2,1)*sqrt(sigmax2*sigmay2);
    covariance(n,:)=[sigmax2 sigmay2 sigmaxy];
    group(n,:)=[start stop];
    start=stop+1;
end


end