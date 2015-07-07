% configure Configure cloud properties
%
% This method changes cloud properties, regenerating data
% as necessary.  A simple call of this method:
%     configure(object);
% shows the current value of all properties that can be changed.  Passing
% name/value pairs allows properties to be changed simultaneously.
%     object=configure(object,name1,value2,name2,value2,...);
%
% See also Cloud
%

%
% created July 5, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=configure(object,varargin)

% manage input
Narg=numel(varargin);
if Narg==0
    assert(nargout==0,'ERROR: output cannot be generated without inputs');   
    name={'VariableName','Moments','Correlations','NumberPoints','Seed','NumberBins'};
    for k=1:numel(name)
        fprintf('%s:\n',name{k});
        if isempty(object.(name{k}))
            fprintf('\t(empty)\n');
        else           
            disp(object.(name{k}));
        end
    end
    return
end
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

refresh=false;
for k=1:2:Narg
    name=varargin{k};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{k+1};
    switch lower(name)
        case 'variablename'
            assert(iscellstr(value),...
                'ERROR: variable names must be a cell array of strings');
            assert(numel(value)==object.NumberVariables,...
                'ERROR: invalid number of variable names');
            object.VariableName=value;
        case 'moments'
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid moments array');
            [M,N]=size(value);
            assert(M==object.NumberVariables,...
                'ERROR: incompatible moments array');
            assert(any(N==[2 3 4]),...
                 'ERROR: incompatible moments array');
             moments=zeros(object.NumberVariables,4);
             moments(:,1:N)=value;
             object.Moments=moments;
             refresh=true;
        case 'correlations'
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid correlation matrix');
            if isempty(value)
                value=eye(object.NumberVariables);
            end
            [M,N]=size(value);
            assert((M==object.NumberVariables) && (M==N),...
                'ERROR: incompatible corelation matrix');
            value=(value+transpose(value))/2; % force symmetry
            valid=(value>=-1) & (value<=+1);
            assert(all(valid(:)),...
                'ERROR: invalid correlation values detected');
            object.Correlations=value;
            refresh=true;
        case 'numberpoints'
            assert(...
                SMASH.General.testNumber(value,'positive','integer'),...
                'ERROR: invalid number of points');
            assert(value>=10*object.NumberVariables,...
                'ERROR: at least 10 points per variable required');
            object.NumberPoints=value;
            refresh=true;
        case 'width'
            assert(isnumeric(value),...
                'ERROR: invalid width setting');
            if isempty(value)
                value=nan(1,object.NumberVariables);
            elseif numel(value)==1
                value=repmat(value,[1 object.NumberVariables]);
            end
            assert(numel(value)==object.NumberVariables,...
                'ERROR: inconsistent width value');
            object.Width=value;
        case 'seed'
            if isnumeric(value) && isscalar(value)
                assert(value==uint32(value),...
                    'ERROR: numeric seeds must be 32-bit unsigned integers');
            elseif ischar(value)
                % do nothing
            else
                error('ERROR: invalid seed value');
            end
            object.Seed=value;
            refresh=true;
        case 'numberbins'
            assert(...
                SMASH.General.testNumber(value,'positive','integer')...
                && (value>0),'ERROR: invalid number of bins');
            object.NumberBins=value;            
        case 'ellipsespan'
            assert(...
                SMASH.General.testNumber(value)...
                && (value>0) && (value<1),...
                'ERROR: invalid ellipse span');
            object.EllipseSpan=value;
        otherwise
            error('ERROR: invalid name');
    end
        
end

% refresh as neccessary
if refresh
    object=regenerate(object);
end

% manage output
if nargout>0
    varargout{1}=object;
end

end