% UNDER CONSTRUCTION
function [points,weights,ielements,group]=drawPoints(object)

% extract active clouds
clouds=object.CloudData(object.ActiveClouds);
N=numel(clouds);

% manage draws
draw=repmat(object.NumberDraws,[N 1]);
% economy mode?

weights=object.CloudWeights;
ielements=nan(N,3);
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
    ielements=object.InverseElements(n,:);    
    group(n,:)=[start stop];
    start=stop+1;
end


end