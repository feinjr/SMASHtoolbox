%%
object=SMASH.MonteCarlo.CurveFit2D();

table=zeros(3,5);
table(:,1)=[0; 1; 2];
table(:,2)=[0; 1; 2];
table(:,3:4)=0.01;
table(end,5)=0.75;
object=add(object,table);

%%
%object=define(object,@StraightLine,[0.5 1],[]);
object=define(object,@StraightLine,[0.9 0.1],[0.8 1.1; -0.5 inf]);
view(object);

new=optimize(object);
view(new);

%%