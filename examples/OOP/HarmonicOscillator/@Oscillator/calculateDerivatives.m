% derivative calculation

function dydt=calculateDerivatives(object,t,y)

% m x'' = -k x - D x'
% y(1) = x
% y(2) = x'
dydt=zeros(2,1);
dydt(1)=y(2);
dydt(2)=(-object.Stiffness*y(1)-object.Damping*y(2))/object.Mass;

end