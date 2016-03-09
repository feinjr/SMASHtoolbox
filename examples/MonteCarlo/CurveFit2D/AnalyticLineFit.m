function varargout=AnalyticLineFit(x,y,dy)

if isscalar(dy)
    dy=repmat(dy,size(x));
end
w=1./dy.^2;

Delta=sum(w)*sum(w.*x.^2)-(sum(w.*x))^2;

A=(sum(w.*x.^2)*sum(w.*y)-sum(w.*x)*sum(w.*x.*y))/Delta;
B=(sum(w)*sum(w.*x.*y)-sum(w.*x)*sum(w.*y))/Delta;

dA=sqrt(sum(w.*x.^2)/Delta);
dB=sqrt(sum(w)/Delta);

% manage output
if nargout==0
    fprintf('Analytic soluction\n');
    fprintf('\tslope    : %#-.4g (%#-.2g uncertainty)\n',B,dB);
    fprintf('\tintercept: %#-.4g (%#-.2g uncertainty)\n',A,dA);
else
    varargout{1}=[B A];
    varargout{2}=[Bvar Avar];
end

end