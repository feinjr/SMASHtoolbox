%% Oscillator
object=Oscillator;
object.InitialPosition=1;
simulate(object,30);

object.Mass=0.25;
simulate(object,30);

object.Damping=0.2;
simulate(object,30);

%% DrivenOscillator
object=DrivenOscillator;
object.DriveFunction=@(t) impulse(t,10);
simulate(object,30)

object.Damping=1;
object.DriveFunction=@(t) impulse(t,10)-impulse(t,30);
simulate(object,60)

object.InitialPosition=10;
object=reset(object);