% single axes figure
% some toggle buttons activate automatically
fig=SMASH.MUI.Figure();
fig.Name='Single axes example';

x=linspace(0,1,1000);
y=cos(2*pi*5*x);
plot(x,y,x,y.^2);
xlabel('Time');
ylabel('Signal');
title('Some oscillating signals');
legend('A','B','Location','NorthEastOutside')
