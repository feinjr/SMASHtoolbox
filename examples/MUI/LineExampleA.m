x=linspace(0,1,100);
y=cos(2*pi*5*x);
objectA=SMASH.MUI.Line(x,y);

y=sin(2*pi*3*x);
objectB=SMASH.MUI.Line(x,y,'Color','r');
