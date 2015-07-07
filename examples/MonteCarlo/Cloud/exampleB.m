%% define cloud
moments=[10 1^2; 20 1^2; 30 1^2];
object=SMASH.MonteCarlo.Cloud(moments);

view(object,'density','ellipse');

%% configure cloud
matrix=eye(3)/2;
matrix(2,3)=0.5;
matrix=(matrix+transpose(matrix));
object=configure(object,'Correlations',matrix,...
    'VariableName',{'X' 'Y' 'Z'});

view(object,'density','ellipse');
view(object,'density','points');

%% transform cloud 
new=transform(object,@transformB);
new=configure(new,'VariableName',{'X+Y','Y+Z'});
view(new);

summarize(object);
summarize(new);

%% transform a large cloud
LargeObject=configure(object,'NumberPoints',1e5,'NumberBins',100);

tic;
new1=transform(LargeObject,@transformB);
toc;
new1=configure(new1,'NumberBins',100);
view(new1);

tic;
new2=transform(LargeObject,@transformBvectorized,'vectorized');
toc;
new2=configure(new2,'NumberBins',100);
view(new2);