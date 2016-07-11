% EVALUATE Prediction for the Gaussian Process at the input array
%
% This method evaluates the Gaussian Process:
%
%    >> [y,dy,mse,dmse]=fit(object,x)
%
% where x is an mxn matrix compatible with the trained GP stored in
% object.DACEFit.
%
% y    : predicted response evaluated at x
% dy   : Gradient of the predictor
% mse  : Estimated mean squared error of predictor
% dmse : Gradient vector/Jacobian matrix of mse
%
% See also GP, fit, evaluate
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
function varargout=evaluate(object,x)

% % handle input
% if (nargin)
%     error('No inputs are required for this method');
% end

% Call predictor function (slight speedup by not returning all outputs)
y = []; dy=[]; mse = []; dmse=[];
if ~iscell(object.DACEFit)
    if nargout == 1
        y = predictor(x,object.DACEFit);
    elseif nargout == 2
        [y,dy] = predictor(x,object.DACEFit);
    elseif nargout == 3
        [y,dy,mse] = predictor(x,object.DACEFit);
    elseif nargout == 4
        [y,dy,mse,dmse] = predictor(x,object.DACEFit);
    end
else
    for i=1:numel(object.DACEFit)
        if nargout == 1
            [yt] = predictor(x,object.DACEFit{i});
            y = [y;yt];
        elseif nargout == 2
            [yt,dyt] = predictor(x,object.DACEFit{i});
            y = [y;yt];
            dy = [dy;dyt];
        elseif nargout == 3
            [yt,dyt,mset] = predictor(x,object.DACEFit{i});
            y = [y;yt];
            dy = [dy;dyt];
            mse = [mse;mset];
        elseif nargout == 4
            [yt,dyt,mset,dmset] = predictor(x,object.DACEFit{i});
            y = [y;yt];
            dy = [dy;dyt];
            mse = [mse;mset];
            dmse = [dmse;dmset];
        end
    end    

end

varargout{1} = y;
varargout{2} = dy;
varargout{3} = mse;
varargout{4} = dmse;  
    
end
    