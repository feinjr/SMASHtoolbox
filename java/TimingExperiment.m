%Niter=logspace(3,10,8);
Niter=logspace(2,10,9);
%Niter=logspace(2,7,6);
%Niter=logspace(3,6,4);

%% Java method
object=TestClass;
resultA=nan(size(Niter));
fprintf('Working on Java method...');
for k=1:numel(Niter)
    tic;
    tempA=testSpeed(object,Niter(k));
    resultA(k)=toc;
end
fprintf('done\n');

%% MATLAB loop with JIT
fprintf('Working on MATLAB loop with JIT...');
feature accel on;
resultB=nan(size(Niter));
for k=1:numel(Niter)
    if (k>1) && (resultB(k-1) > 30)
        break
    end
    tic;
    tempB=0;
    for m=1:Niter(k)
        tempB=tempB+1;
    end
    resultB(k)=toc;
end
fprintf('done\n');

%% MATLAB loop without JIT
fprintf('Working on MATLAB loop without JIT...');
feature accel off
resultC=nan(size(Niter));
for k=1:numel(Niter)
    if (k>1) && (resultC(k-1) > 30)
        break
    end
    tic;
    tempC=0;
    for m=1:Niter(k)
        tempC=tempB+1;
    end
    resultC(k)=toc;
end
feature accel on
fprintf('done\n');

%% MATLAB vectorization
fprintf('Working on MATLAB vectorized approach...');
resultD=nan(size(Niter));
for k=1:numel(Niter)
    tic;
    temp=ones(1,Niter(k));
    temp=sum(temp);
    resultD(k)=toc;
end
fprintf('done\n');

%%
plot(Niter,resultA,Niter,resultB,Niter,resultC,Niter,resultD);
set(gca,'XScale','log','YScale','log');
xlabel('Number of loops');
ylabel('Total loop time (seconds)');

legend('Java method',...
    'MATLAB loop (JIT on)','MATLAB loop (JIT off)','Vectorized MATLAB',...
    'Location','northwest');
set(gca,'XTick',10.^(2:10))

title(version);

set(gcf,'Units','inches','PaperPositionMode','auto','Position',[0 0 5 5],...
    'PaperSize',[5 5]);
grid on
movegui(gcf,'northeast');