% [x,y]=normalize(xm,ym,'setup');
% [x,y]=normalize(xm,ym,'previous');
% [xm,ym]=normalize(x,y,'undo');

function [out1,out2]=normalize(in1,in2,mode)

persistent xbound ybound;
if strcmp(mode,'setup')
    xbound=[min(in1(:)) max(in1(:))];
    ybound=[min(in2(:)) max(in2(:))];
end

switch mode
    case 'undo'
        out1=(xbound(2)-xbound(1))*in1+xbound(1);
        out2=(ybound(2)-ybound(1))*in2+ybound(1);
    otherwise % apply existing normalization
        out1=(in1-xbound(1))/(xbound(2)-xbound(1));
        out2=(in2-ybound(1))/(ybound(2)-ybound(1));
end


end