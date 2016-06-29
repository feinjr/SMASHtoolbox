%% create objects
t=0:0.01:1;
s=cos(2*pi*t)+0.1*randn(size(t));
measurementA=SMASH.SignalAnalysis.Signal(t,s);

t=0.75:0.02:2;
s=cos(2*pi*t)+0.1*randn(size(t));
measurementB=SMASH.SignalAnalysis.Signal(t,s);

% merge objects
combined=merge(measurementA,measurementB);

view(combined);
measurementA.GraphicOptions.LineStyle='none';
measurementA.GraphicOptions.Marker='o';
view(measurementA,gca);

measurementB.GraphicOptions.LineStyle='none';
measurementB.GraphicOptions.Marker='s';
view(measurementB,gca);