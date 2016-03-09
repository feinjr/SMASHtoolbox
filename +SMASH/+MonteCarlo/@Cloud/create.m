function object=create(object,varargin)

Narg=numel(varargin);
if (Narg==2) && strcmpi(varargin{2},'table')
    table=varargin{1};
    assert(isnumeric(table) & ismatrix(table),'ERROR: invalid data table');
    [object.NumberPoints,object.NumberVariables]=size(table);
    assert(object.NumberPoints>=5,...
        'ERROR: at least 5 points needed to make a cloud');
    object.Data=table;    
    [moments,correlations]=summarize(object);
    object.Moments=moments;
    object.Correlations=correlations;
    object.Source='table';
elseif any(Narg==[1 2 3])
    object.NumberVariables=size(varargin{1},1);
    switch Narg
        case 1
            object=configure(object,...
                'Moments',varargin{1},...
                'Correlations',eye(object.NumberVariables));
        case 2
            object=configure(object,...
                'Moments',varargin{1},...
                'Correlations',varargin{2});
        case 3
            object=configure(object,...
                'Moments',varargin{1},...
                'Correlations',varargin{2},...
                'NumberPoints',varargin{3});
    end            
    object.Source='moments';    
else
    error('ERROR: invalid number of inputs');
end

% generate labels and widths
object.VariableName=cell(1,object.NumberVariables);
for n=1:object.NumberVariables
    object.VariableName{n}=sprintf('Variable #%d',n);
end

% density options
object.DensitySettings.GridPoints=100;
object.DensitySettings.SmoothFactor=2;
object.DensitySettings.PadFactor=5;
object.DensitySettings.NumberContours=5;

end