% This function evaluates the Debye function:
%
%     >> D(x) = Debye3(n,x);
%
% where n is the order of the function.
%
% created January 15, 2014 by Justin Brown (Sandia National Laboratories)
%
function D = DebyeFunction(n,x)
    
    D=zeros(size(x)); 
    
    %Define Debye function handle
    DIntegrand = @(x) (x.^n)./(exp(x)-1);
    
    %Calculate the function for each x
    for i = 1:numel(x)
        D(i) = 3./x(i).^3.*integral(DIntegrand,0,x(i));
    end

end