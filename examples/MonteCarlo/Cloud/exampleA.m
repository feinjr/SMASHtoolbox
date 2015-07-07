%% object creation and basic visualization
moments=[0 1^2; 0 2^2];
object=SMASH.MonteCarlo.Cloud(moments);

plot(object.Data(:,1),object.Data(:,2),'.');
axis equal;

%% summary and confidence regions
summarize(object);

confidence(object);

%% visualization
view(object);

object=configure(object,'NumberBins',20);
view(object);

view(object,'density','density');

view(object,'density','ellipse');

view(object,'','points');

%% saving for later
SMASH.FileAccess.writeFile('myclouds.sda','first cloud',object);

SMASH.FileAccess.probeFile('myclouds.sda')
previous=SMASH.FileAccess.readFile('myclouds.sda','sda','first cloud');