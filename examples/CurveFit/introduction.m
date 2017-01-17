% These examples illustrate two basic curve fits with straight. The first
% example uses a line with zero slope, which is effectively the same thing
% as averaging.  The second example uses a straightly line with a non-zero
% slope.  Analytic solutions for the parameters and uncertainties are
% available for both examples, making them useful test cases for Curve
% class.
%

%% 
close all
clear
clc

%% flat line
x=linspace(0,1,1000);
y=+1*randn(size(x));
data=[x(:) y(:)];

object=SMASH.CurveFit.Curve;
object=add(object,@(p,x) ones(size(x)),[]);

object=fit(object,data);

for N=[1e3 1e4]
    report=analyze(object,data,N);
    fprintf('Flat line analyzed with %d iterations\n',N);
    fprintf('\tAnalytic mean  : %#.4g +/- %#.3g\n',...
        mean(y),std(y)/sqrt(numel(y)));
    fprintf('\tEstimated mean : %#.4g +/- %#.3g\n',...
        object.Scale{1},sqrt(report.Moments(2)));
end
fprintf('\n');

figure;
plot(x,y,'r',x,evaluate(object,x),'k');

%% straight line
y=x+0.1*randn(size(x));
data=[x(:) y(:)];

object=SMASH.CurveFit.Curve;
object=add(object,@(p,x) ones(size(x)),[]);
object=add(object,@(p,x) x,[]);

object=fit(object,data);

M=numel(x);
Delta=M*sum(x.^2)-(sum(x)).^2;
A=(sum(x.^2)*sum(y)-sum(x)*sum(x.*y))/Delta;
B=(M*sum(x.*y)-sum(x)*sum(y))/Delta;
sigmay=sqrt(sum((y-A-B*x).^2)/(M-2));
sigmaA=sigmay*sqrt(sum(x.^2)/Delta);
sigmaB=sigmay*sqrt(M/Delta);

N=1e4;
report=analyze(object,data,N);
fprintf('Straight line analyzed with %d iterations\n',N);
a=polyfit(x,y,1);
fprintf('\tAnalytic slope  : %#.4g +/- %#.3g\n',...
    B,sigmaB);
fprintf('\tEstimated slope : %#.4g +/- %#.3g\n',...
    object.Scale{2},sqrt(report.Moments(2,2)));
fprintf('\tAnalytic intercept  : %#.4g +/- %#.3g\n',...
    A,sigmaA);
fprintf('\tEstimated intercept : %#.4g +/- %#.3g\n',...
    object.Scale{1},sqrt(report.Moments(1,2)));
fprintf('\n');

figure;
plot(x,y,'r',x,evaluate(object,x),'k');

report=configure(report,'VariableName',{'Intercept' 'Slope'});
view(report);
summarize(report);