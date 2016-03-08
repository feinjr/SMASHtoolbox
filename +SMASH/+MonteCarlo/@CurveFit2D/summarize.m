% summarize Summarize curve
%
% This function summarizes the measurements and model for a CurveFit2D
% object.  When the method is called with no output:
%    summarize(object);
% the summary is printed in the command window.  The summary can also be
% directed to output arguments.
%    [measurement,model]=summarize(object);
%
% See also CurveFit2D, add, remove, view
%

%
% created March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
% 
function varargout=summarize(object)

% measurement summary
N=object.NumberMeasurements;
measurement=nan(N,3);
for n=1:N
    measurement(n,1)=n;
    measurement(n,2:3)=object.MeasurementDensity{n}.Original.Mean;
end

% model summary
model=struct();
if isempty(object.Model)
    model.Function='(not defined)';
    model.Parameter='(not defined)';
else
    model.Function=func2str(object.Model);
    model.Parameter=object.Parameter;
end

% manage output
if nargout==0
    fprintf('Curve meaurements\n');
    if size(measurement,1)==0
        fprintf(' (none)\n');
    else
        fprintf(' %10s %10s %10s\n','Index','X mean','Y mean');
        fprintf(' %10d %#+10.3g %#+10.3g\n',transpose(measurement));
    end
    fprintf('Curve model\n');
    fprintf('   Function : %s\n',model.Function);
    fprintf('   Parameter: ');
    if isnumeric(model.Parameter)
        format='%#+15.5g ';
    else        
        format='%s';  
    end
    fprintf(format,model.Parameter);  
    fprintf('\n');
else
    varargout{1}=measurement;
    varargout{2}=model;
end

end