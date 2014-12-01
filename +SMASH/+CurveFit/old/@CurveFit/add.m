% add basis
%
%    >> object=add(object,basis,guess);
%
%    >> object=add(...,'lower',bound);
%    >> object=add(...,'upper,bound);
%
%    >> object=add(...,'scalable',true);
%    >> object=add(...,'scalable,false);
function object=add(object,basis,guess,varargin)

% handle input
assert(nargin>=3,'ERROR: insufficient input');

if ischar(basis)
    basis=str2func(basis);
end
assert(isa(basis,'function_handle'),'ERROR: invalid basis function');

assert(isnumeric(guess) & (numel(guess)>0),'ERROR: invalid guess array');
Nparam=numel(guess);
guess=reshape(guess,[1 Nparam]);

option=struct('Lower',-inf(1,Nparam),'Upper',+inf(1,Nparam),'Scalable',true);
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{n+1};
    switch lower(name)
        case 'lower'
            if isempty(value)
                value=-inf;
            end
            if numel(value)==1
                value=repmat(value,[1 Nparam]);
            end
            assert(numel(value)==Nparam,'ERROR: invalid lower bound');
            option.Lower=reshape(value,[1 Nparam]);
        case 'upper'
            if isempty(value)
                value=+inf;
            end
            if numel(value)==1
                value=repmat(value,[1 Nparam]);
            end
            assert(numel(value)==Nparam,'ERROR: invalid upper bound');
            option.Upper=reshape(value,[1 Nparam]);
        case 'scalable'
            assert(islogical(value) & (numel(value)==1),...
                'ERROR: scalable must be true or false');
            option.Scalable=value;
        otherwise
            error('ERROR: ''%s'' is an invalid name',name);
    end
end

assert(all(option.Upper>=option.Lower),'ERROR: inconsistent bounds');

% update object
object.BasisFunction{end+1}=basis;
Nbasis=numel(object.BasisFunction);
object.Scalable(Nbasis)=option.Scalable;

index=numel(object.Guess)+(1:Nparam);
object.Guess(index)=guess;
object.LowerBound(index)=option.Lower;
object.UpperBound(index)=option.Upper;

object.BasisIndex(index)=Nbasis;


object=reset(object);

end