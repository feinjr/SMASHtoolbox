% view Display sinusoid fit
%
% This method displays the signal and optimized result (when present) of a
% SinusoidFit object.
%    view(object);
%    h=view(object); % return graphic handles
%
% See also SinusoidFit, optimize
%

%
% created March 22, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object)

figure;

h(1)=plot(object.Time,object.Signal,'r');
xlabel('Time');
ylabel('Signal');

if isempty(object.Curve)
    legend('Measurement','Location','best');
else
    h(2)=line(object.Time,object.Curve,'Color','k');
    legend('Measurement','Fit curve','Location','best');
end


if nargout>0
    varargout=h;
end

end