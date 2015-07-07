% LOCATE Locate feature in an object
%
% This method locates features in a Signal object.  By default,
% the feature is assumed to be a single Gaussian peak.
%    >> report=locate(object);
% The output structure "report" contains information about the located
% feature.  If no output is specified, the results are plotted to a new
% figure.
% 
% Single Gaussian peak location can be explicitly requested with a second
% input argument.
%    >> report=locate(object,'peak');
% Step location based on the error function is also provided.
%    >> report=locate(object,'step');    
% Custom features may be requested by passing a function handle  that
% provides the desired fit.
%    >> report=locate(object,@myfit);
% The fit function must accept two inputs (x,y) and return a structure
% reporting results of the fit.  One field of this structure, 'Location',
% should identifying the feature's location; additional fields can be used
% as necessary.  For reference, the default fit function provides fields
% for 'Method', 'Description', 'Location', 'Width', 'Amplitude',
% 'Baseline', 'Parameters', and 'Fit'.
%
% See also Signal
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=locate(object,curvefit,guess)

% manage input
if (nargin<2) || isempty(curvefit) || strcmpi(curvefit,'peak') ...
        || strcmpi(curvefit,'gaussian')
    curve='gauss';
elseif strcmpi(curvefit,'step')
    curve='erf';
end

if nargin<3
    guess=[];
end

% apply curvefit
[x,y]=limit(object);
try
    switch curve
        case 'gauss'
            report=gaussfit(x,y,guess);
        case 'step'
            report=erffit(x,y,guess);
    end
catch
    message={};
    message{end+1}='ERROR: locate failed';
    error('%s\n',message{:});
end

% handle output
if nargout==0   
    view(object);
    line(x,report.Fit,'Color','k','LineStyle','--');
    label=sprintf('Location = %#+g',report.Location);
    title(label);
else
    varargout{1}=report;
end

end