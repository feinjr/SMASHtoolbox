function [center,param]=findCenter(time,phase,amplitude)

t0=time(1);
duration=time(end)-t0;
time=(time-t0)/duration;
time=time(:);
N=numel(time);

phase=phase(:);


weight=min(amplitude);
weight=(amplitude-weight)/(max(amplitude)-weight);
weight=weight(:).^4;

order=3;
matrix=ones(N,order+1);
for k=1:order
    matrix(:,k+1)=time.^k;
end

vectorW=weight.*phase;
matrixW=bsxfun(@times,matrix,weight);
param=matrixW\vectorW;
fit=matrix*param;

param=param(end:-1:1);
%ti=roots(polyder(polyder(param)));
%ti=t0+ti*duration;

[~,index]=max(weight);
theta=interp1(time,phase,time(index));
theta=pi*round(theta/pi);
solutionA=roots(param-[0 0 0 theta+pi]');
[~,index]=min(abs(imag(solutionA)));
soluationA=solutionA(index);

solutionB=roots(param-[0 0 0 theta-pi]');
[~,index]=min(abs(imag(solutionB)));
soluationB=solutionB(index);

solution=(soluationA+soluationB)/2;
% solution=roots(param-[0 0 0 theta]');
% keep=(real(solution) > 0) & (real(solution) <1) & (abs(angle(solution))<1e-9);
% solution=solution(keep);
% if numel(solution) ==3
%     %solution=solution(2);    
%     solution=mean(solution);
% end


center=t0+solution*duration;

end