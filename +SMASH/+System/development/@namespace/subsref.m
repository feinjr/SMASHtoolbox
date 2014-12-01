% custom object referencing
function varargout=subsref(object,arg)

switch arg(1).type
    case '.'
        name=arg(1).subs;
        result=cellfun(@(x) strcmp(x,name),object.Names);
        assert(sum(result)>0,'ERROR: invalid name');                
        index=find(result,1,'last');
        varargout=cell(1,nargout);
        if numel(arg)>1
            in=arg(2).subs;
        else
            in={};
        end
        [varargout{:}]=feval(object.Handles{index},in{:});
    otherwise
        error('ERROR: invalid object access');
end
    

end