%% three signal text file
time=linspace(0,10,100);
time=time(:);
data=[time cos(2*pi*time) sin(2*pi*time) ones(size(time))];
SMASH.FileAccess.writeFile('mydata.txt',data);