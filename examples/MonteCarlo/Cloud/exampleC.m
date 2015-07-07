%% define cloud
moments=[10 1^2; 20 1^2];
object=SMASH.MonteCarlo.Cloud(moments);

view(object,'density','ellipse');

%% transform cloud 
clc
new=transform(object,@transformC1);
new=configure(new,'VariableName',{'X','X^2/Y'});
view(new,'density','points');

summarize(object);
summarize(new);

%% transform cloud 
clc
new=transform(object,@transformC2);
new=configure(new,'VariableName',{'X','X*Y'});
view(new,'density','points');

summarize(object);
summarize(new);
