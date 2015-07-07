%% what does skewness do?
value=0.75;
object=SMASH.MonteCarlo.Cloud([0 1 0 0; 0 1^2 value 0]);
view(object,'density','density')

object=SMASH.MonteCarlo.Cloud([0 1 0 0; 0 1^2 -value 0]);
view(object,'density','density')

%% what does kurtosis do?
value=1;
object=SMASH.MonteCarlo.Cloud([0 1 0 0; 0 1^2 0 value]);
view(object,'density','density')

object=SMASH.MonteCarlo.Cloud([0 1 0 0; 0 1^2 0 -value]);
view(object,'density','density')