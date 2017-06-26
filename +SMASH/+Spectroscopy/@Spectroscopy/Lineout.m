function [x,y]=Lineout(ImageData,y1,y2,x1,x2,direction)
if direction=='X'
    pixel=x1:1:x2;
    AveDir=1;
elseif direction=='Y'
    pixel=y1:1:y2;
    AveDir=2;
end
MatrixSec=ImageData(y1:y2,x1:x2);
average=double(mean(MatrixSec,AveDir));
x=pixel(:);
y=average(:);
end
