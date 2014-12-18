%% example A
object=SimpleHarmonicOscillator;
object.InitialPosition=1;

omega=sqrt(object.Stiffness/object.Mass);
period=2*pi/omega;
simulate(object,60);
fprintf('period=%g\n',period);

%% example B
object=SimpleHarmonicOscillator;
object.InitialPosition=1;
object.Mass=2;

omega=sqrt(object.Stiffness/object.Mass);
period=2*pi/omega;
simulate(object,60);
fprintf('period=%g\n',period);

%% example C
object=SimpleHarmonicOscillator;
object.InitialPosition=1;
object.Damping=0.2;

simulate(object,60);

%% example D
object=DrivenHarmonicOscillator;
object.DriveFunction=@(x,t) exp(-(t-10).^2/(2*1^2));
object.Damping=0.2;

simulate(object,60)

%% example E
object=DrivenHarmonicOscillator;
object.DriveFunction=@(x,t) 100*exp(-(t-10).^2/(2*0.01^2));
object.Damping=0.2;

simulate(object,60)

option=odeset('MaxStep',0.01);
simulate(object,60,option);