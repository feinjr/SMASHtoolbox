figure;

%% compare FFT approach with direct method
q=10+2*randn(1e5,1);

tic;
[w1,x1]=SMASH.MonteCarlo.density1('bin',q,20);
time(1)=toc;

tic;
[w2,x2]=SMASH.MonteCarlo.density1('direct',q,1000);
time(2)=toc;

tic;
[w3,x3]=SMASH.MonteCarlo.density1('fft',q,1000);
time(3)=toc;

fprintf('Direct: %#.3g \n',time(2)/time(1));
fprintf('FFT: %#.3g \n',time(3)/time(1));

subplot(2,2,1);
bar(x1,w1,1,'FaceColor','none');
line(x2,w2,'Color','r');
xlabel('Value');
ylabel('Probability density');
title('Direct approach');
axis tight;

subplot(2,2,2);
bar(x1,w1,1,'FaceColor','none');
line(x3,w3,'Color','r');
xlabel('Value');
ylabel('Probability density');
title('FFT approach');
axis tight;

err=max(abs(interp1(x2,w2,x3)-w3))/max(w2);

%% time comparison
subplot(2,2,[3 4]);

M=round(logspace(1,7,20));
t1=nan(1,numel(M));
t2=t1;
for m=1:numel(M);
    xm=randn(M(m),1);
    tic;
    [~,~]=SMASH.MonteCarlo.density1('fft',xm,1024);
    t1(m)=toc;
    tic;
    if M(m)<2e5
        [~,~]=SMASH.MonteCarlo.density1('direct',xm,1024);
        t2(m)=toc;
    end
end

plot(M,t1,M,t2);
xlabel('Number of measurments');
ylabel('Computation time (s)');
set(gca,'XScale','log','YScale','log');
legend('FFT','Direct','Location','northwest');
