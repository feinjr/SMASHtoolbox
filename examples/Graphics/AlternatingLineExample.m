%% create new axes
figure;
axes;
axis auto
set(gca,'Color',repmat(0.5,[1 3]));

%% curve
x=linspace(0,10,200);
y=cos(2*pi*x);

h(1)=SMASH.Graphics.AlternatingLine(x,y);

%% closed rectangle
x=[1 9 9 1];
y=[0.1 0.1 0.9 0.9];
x(end+1)=x(1);
y(end+1)=y(1);

h(2)=SMASH.Graphics.AlternatingLine(x,y);
set(h(2),'ForegroundColor','red');

%% ellipse
theta=linspace(0,2*pi,100);
x=5+2*cos(theta);
y=0.5+sin(theta);

h(3)=SMASH.Graphics.AlternatingLine(x,y,...
    'BackgroundColor','cyan','ForegroundColor','magenta');
reverse(h(3));