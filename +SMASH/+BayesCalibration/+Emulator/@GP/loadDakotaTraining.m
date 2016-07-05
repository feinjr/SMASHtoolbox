% Load a dakota training data set
%
% This method loads the tabular_data file from a Dakota training simulation
%    >> object=loadDakotaTraining(object,'fidID');
%
% Options can be included as
%    >> object=loadDakotaTraining(object,'fidID','Option',OptionValue);
% 
% Valid options include:
%   'DefineGrid', 'filename.dat' where dlmread is used to load the file
%   'DefineGrid', array of values
%   'ResponseStride', scalar value
%   'BuildStride' , scalar value
%
% See also GP, evaluate, fit
% 

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
function object=fit(object,varargin)

Narg=numel(varargin);

%Error checking
if ~ischar(varargin{1})
    error('ERROR : Requires a Dakota tabular_data file name');
end

options = [];
if Narg > 1 
    Noptions = (Narg-1);
    if rem(Noptions/2,1) ~=0
        error('ERROR : Invalid option settings');
    end
    options = varargin(2:2:Noptions);    
    optionvals = varargin(3:2:Noptions+1);  
    
end   
    
% Initial Parsing
lhs = importdata(varargin{1});
header = lhs.textdata;
trainingdata = lhs.data;

%Scan first row for number of response
[nrow,ncol] = size(header);
nresp = 0;
for i = 1:ncol
    k = strfind(header{1,i},'response');
    if k; nresp = nresp+1; end
end
nvars = ncol-2-nresp;

VarNames = [];
for i = 1:nvars
    VarNames{i} = header{1,2+i};
end
ResNames = [];
for i = 1:nresp
    ResNames{i} = header{1,2+nvars+i};
end

%Parse training data
vars = trainingdata(:,1:nvars);
response = trainingdata(:,nvars+1:end);
grid = 1:nresp';


if ~isempty(options)
    validoptions = {'DefineGrid','ResponseStride','BuildStride','VariableTrim','ResponseTrim'};
    for i=1:numel(options);
        validStr{i} = validatestring(options{i},validoptions);
    end
    
    DG = strcmpi(validoptions{1},validStr);
    RS = strcmpi(validoptions{2},validStr);
    BS = strcmpi(validoptions{3},validStr);
    VT = strcmpi(validoptions{4},validStr);
    RT = strcmpi(validoptions{5},validStr);
    
    % Define grid option first
    if any(DG)
        gridoption = optionvals{DG};
        if ischar(gridoption)
            grid = dlmread(gridoption);
        elseif isnumeric(gridoption) && isvector(gridoption)
            grid = gridoption;
        else
            error('ERROR : Invalid grid format');
        end
    end
    
    %Trim responses
    if any(RT)
        rtrim = optionvals{RT};
        if ~isvector(rtrim)
            error('ERROR : Variable trim must be a vector')
        end
        response = response(:,rtrim);
        ResNames = ResNames(rtrim);
        grid = grid(rtrim);
    end
       
    %Trim variables
    if any(VT)
        vtrim = optionvals{VT};
        if ~isvector(vtrim)
            error('ERROR : Variable trim must be a vector')
        end
        vars = vars(:,vtrim);
        VarNames = VarNames(vtrim);
    end
    

    % Thin number of residuals
    if any(RS)
        rstride = optionvals{RS};
        if ~isscalar(rstride)
            error('ERROR : ResidualStride must be a scalar value')
        end
        if rstride > 1
            [nrow ncol] = size(response);
            thin = 1:rstride:ncol;
            response = response(:,thin);
            grid = grid(thin);
            ResNames = ResNames(thin);
        end
    end
    
    % Thin number of build points
    if any(BS)
        bstride = optionvals{BS};
        if ~isscalar(rstride)
            error('ERROR : ResidualStride must be a scalar value')
        end
        if bstride > 1
            [nrow ncol] = size(response);
            thin = 1:bstride:nrow;
            response = response(thin,:);
            vars = vars(thin,:);
        end
    end
end

[nbuild nresp] = size(response);
[nbuild nvars] = size(vars);

object.VariableNames = VarNames;
object.ResponseNames = ResNames;
object.NumberVariables = nvars;
object.NumberResponses = nresp;
object.VariableData = vars;
object.ResponseData = response;
object.Grid = grid;
    

object.Settings.Theta0 = ones(1,object.NumberVariables);
object.Settings.Theta0_LowerBound = ones(1,object.NumberVariables)*1e-4;
object.Settings.Theta0_UpperBound = ones(1,object.NumberVariables)*1e4;
    
    
end