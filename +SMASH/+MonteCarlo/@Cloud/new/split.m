function varargout=split(object,varargin)

% manage input
Narg=numel(varargin);
if nargout>Narg
    error('ERROR: too many outputs');
elseif Narg>nargout
    warning('Ignoring extra inputs');
end
valid=1:object.NumberVariables;
for m=1:Narg
    for n=1:numel(varargin)
        assert(any(varargin{m}(n)==valid),...
            'ERROR: invalid variable requested');
    end
end

% manage output
varargout=cell(1,nargout);
for m=1:nargout
    index=varargin{m};
    temp=object;
    temp.Data=temp.Data(:,index);
    temp.Moments=temp.Moments(index,:);
    temp.NumberVariables=numel(index);
    M=numel(index);
    matrix=nan(M);
    for row=1:M
        for column=1:M
            matrix(row,column)=temp.Correlations(index(row),index(column));
        end
    end
    temp.Correlations=matrix;  
    temp.VariableName=temp.VariableName(index);
    temp.Width=temp.Width(index);
    temp.Source='split';    
    varargout{m}=temp;
end

end