function [X,Y,DX,DY,direction,weight]=initialize(object)

% set up cloud arrays
[X,Y]=deal(nan(object.NumberClouds,object.CloudSize));
for k=1:object.NumberClouds
    temp=object.Clouds{k};
    if temp.CloudSize ~= object.CloudSize
        temp=bootstrap(temp);
    end
    X(k,:)=reshape(temp.Data(:,1),[1 object.CloudSize]);
    Y(k,:)=reshape(temp.Data(:,2),[1 object.CloudSize]);
end

% apply normalization
X=normalize(X,'setup');
Y=normalize(Y,'setup');

% set up shift arrays
[DX,DY]=deal(nan(object.NumberClouds,object.CloudSize));
for k=1:object.NumberClouds
    DX(k,:)=X-mean(X(k,:));
    DY(k,:)=Y-mean(X(Y,:));
end

% set up direction array

% set up weight array


end