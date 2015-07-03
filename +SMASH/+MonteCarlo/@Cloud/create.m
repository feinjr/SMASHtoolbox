function object=create(object,varargin)

Narg=numel(varargin);
if (Narg==2) && strcmpi(varargin{2},'table')
    table=varargin{1};
    assert(isnumeric(table) & ismatrix(table),'ERROR: invalid data table');
    [object.NumberPoints,object.NumberVariables]=size(table);
    object.Data=table;    
    [moments,correlations]=summarize(object);
    object.Moments=moments;
    object.Correlations=correlations;
    object.Source='table';
else
    table=varargin{1};
    assert(isnumeric(table) & ismatrix(table),'ERROR: invalid moments table');
    [Nvariable,Nmoments]=size(varargin{1});
    assert((Nmoments>=2) & (Nmoments<=4),'ERROR: invalid moments table');
    object.Moments=varargin{1};
    object.NumberVariables=Nvariable;    
    object.Correlations=eye(Nvariable);
    if (Narg>=2) && ~isempty(varargin{2})
        assert(ismatrix(varargin{2}) & all(size(object.Correlations)==Nvariable),...
            'ERROR: invalid correlation matrix');
        object.Correlations=varargin{2};
    end    
    if (Narg>=3) && ~isempty(varargin{3})
        object.NumberPoints=varargin{3};
    end
    object=regenerate(object);
    object.Source='moments';    
end

% generate labels and widths
object.VariableName=cell(1,object.NumberVariables);
for n=1:object.NumberVariables
    object.VariableName{n}=sprintf('Variable #%d',n);
end

object.Width=nan(1,object.NumberVariables);

end