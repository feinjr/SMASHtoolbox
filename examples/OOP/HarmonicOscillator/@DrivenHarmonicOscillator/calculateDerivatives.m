%

function dydt=calculateDerivatives(object,t,y)

% m x'' = -k x - D x' + F
% y(1) = x
% y(2) = x'
dydt=calculateDerivatives@SimpleHarmonicOscillator(object,t,y);
if ~isempty(object.DriveFunction)
    try
        dydt(2)=dydt(2)+object.DriveFunction(y(1),t)/object.Mass;
    catch
        error('ERROR: invalid drive function');
    end
end
end