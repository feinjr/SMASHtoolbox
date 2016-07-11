function varargout = ExampleAFunc(object,x)
    mu = [-1;2]; 
    varargout{1} = x'- mu;
    
    if nargout > 1
        varargout{2} = [4,0;0,1];
    end
end