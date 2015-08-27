% UNDER CONSTRUCTION
function varargout=configure(object,varargin)

% mange input
Narg=numel(varargin);
if Narg==0
    assert(nargout==0,'ERROR: no output can be generated without input');
    disp(object.Settings);    
    return
end

assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

setting=object.Settings;
valid=fieldnames(setting);
Nfield=numel(valid);
for m=1:2:Narg
    name=varargin{m};
    assert(ischar(name),'ERROR: invalid name');
    found=false;
    for n=1:Nfield
        if strcmpi(name,valid{n})            
            found=true;
            break
        end
    end
    setting.(valid{n})=varargin{m+1};
    assert(found,'ERROR: %s is an invalid name');
end

% error checking
value=setting.StepLevels;
if isempty(value)
    value=object.DefaultStepLevels;
end
assert(isnumeric(value) && numel(value)>1 && all(value>=0),...
    'ERROR: invalid StepLevels value');
value=reshape(value,[1 numel(value)]);
value=sort(value);
setting.StepLevels=value;

value=setting.StepOffsets;
if isempty(value)
    value=object.DefaultStepOffsets;
end
assert(isnumeric(value) & numel(value)>0 & all(value>=0),...
    'ERROR: invalid StepOffsets value');
value=reshape(value,[1 numel(value)]);
value=sort(value);
setting.StepOffsets=value;

value=setting.DerivativeParams;
if isempty(value)
    value=object.DefaultDerivativeParams;
end
assert(isnumeric(value) & numel(value==2) ...
    & all(value>0),...
    'ERROR: invalid DerivativeParams value');
setting.DerivativeParams=value;

% finish up
object.Settings=setting;
varargout{1}=object;

end   
    %         function object=set.CalibrationRange(object,value)
    %             if isempty(value)
    %                 value=[0.025 0.975];
    %             end
    %             assert(isnumeric(value) & numel(value==2) ...
    %                 & all(value>0) & all(value<1),...
    %                 'ERROR: invalid CalibrationRange value');
    %             value=sort(value);
    %             object.CalibrationRange=value;
    %         end
    