% optimize Optimize model parameters
%
% This method optimizes model parameters against the measurements defined
% in a CurveFit2D object.
%    object=optimize(object); % use options defined in the object
%    object=optimize(object,options); % manual options (see optimset function)
% NOTE: the behavior of this method is senstivie to the AssumeNormal
% property!
%


% By default, this method generates a warning if the optimized curve does
% not pass near every measurment.  This warning can be suppressed as
% follows.
%    object=optimize(object,[],'silent'); % use default options
%    object=optimize(object,options,'silent');
% A logical array indicating measurements missed by the optimized curve is
% returned as a second output.
%    [object,miss]=optimize(...);
%
% See also CurveFit2D, analyze
%

%
% creaed March 8, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function [object,flag]=optimize(object)%,silent)


%if (nargin<3) || isempty(silent) || strcmpi(silent,'verbose')
%    silent=false;
%elseif strcmpi(silent,'silent')
%    silent=true;
%else
%    error('ERROR: invalid silent input');
%end

% perform optimization
options=object.OptimizationSettings;
options.Display='none';
[slack,~,flag]=fminsearch(@(p) -examine(object,p,'slack'),object.Slack,...
    options);
object=evaluate(object,'slack',slack);

object.Optimized=true;

% if ~silent && any(miss)
%     message={};
%     message{end+1}='Optimized mode misses one or more measurements:';
%     message{end+1}='   -A better parameter guess may resolve this problem.';
%     message{end+1}='   -A different model may be more appropriate.';
%     message{end+1}='   -Specified measurement variances may be too low.';
%     message{end+1}='   -There may be measurement outliers.';   
%     warning('SMASH:Curvefit2D','%s\n',message{:});
% end

end