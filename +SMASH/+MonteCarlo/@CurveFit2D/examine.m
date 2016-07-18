% examine Evalualte likelihood for a specific parameter state
%
% This function evaluates the relative likelihood of a parameter state for
% the current model function and measurements.
%    likelihood=examine(object,parameter);
% NOTE: the result is the sum of the peak density logaritms, i.e. the
% maximum density of the model curve passing through each measurement.
% These densities are *not* normalized, but ratios can be useful.  The
% relative probability of a second parameter state relative to the first
% state is thus 10^(L2-L1).
%

%
% created July 18, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function likelihood=examine(object,parameter,mode)

% manage input
if (nargin<2) || isempty(parameter)
    parameter=object.Parameter;
end

if (nargin<3) || isempty(mode)
    mode='parameter';
end

M=object.NumberMeasurements;
%fid=fopen('iteration.log','w');
%cleanup=onCleanup(@() fclose(fid));

object=evaluate(object,mode,parameter);
%fprintf(fid,'%10g ',object.Parameter);
maxdensity=zeros(1,M);
maxlocation=nan(M,2);
for m=1:M % iterate over measurements
    measurement=object.MeasurementDensity{m};
    if object.AssumeNormal
        [temp,location]=findmax(measurement,'original',...
            object.CurvePoints,'normal');
    else
        [temp,location]=findmax(measurement,'original',...
            object.CurvePoints,'general');
    end
    maxdensity(m)=temp;
    maxlocation(m,:)=location;
    %if any(isnan(location))
    %    miss(m)=true;
    %end
end
likelihood=sum(log(maxdensity))/M;
%fprintf(fid,'%10g\n',value);

end