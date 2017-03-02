function Formula = TranslateChem(str)
%% Formula = TranslateChem(str)
%  This function takes a chemical formula string (i.e. SiO2, silicon
%  dioxide) and parses it to return each element in the formula and its
%  quantity.  For 'SiO2' it returns 1 'Si' and 2 'O'
%
%   Input: str - formula string.  This must be in standard notation, i.e.
%   each element must conform to its symbol on the periodic table.
%   Elements with a single letter are Caps, elements with two letters must
%   have a lower case second letter.
%   
%   Output: Formula - 1xn structure with fields 'name' and 'quantity' where
%   n is the number of elements present in the compound
%   
%   Written By: Patrick Knapp
%   Written On: 8/12/2011
%%
num=regexp(str,'\d+','match');  % cell array containing the numbers
D = isstrprop(str,'digit'); %logical array giving location of numbers
U = isstrprop(str,'upper'); %logical giving location of upper case alphas   
L = isstrprop(str,'lower'); %logical giving location of lower case alphas

NumElem = sum(U);   %number of upper case alphas == number of elements in formula
Formula = struct('element',{},'quantity',{}); %initialize output

%% Loop through formula to extract quantities
n = 1;
num_counter = 1;

for i = 1:NumElem    
    if U(n) && n < numel(str)
        if U(n) && L(n+1)
            Formula(i).element = str(n:n+1);
            n = n+2;
            if ~D(n)
                Formula(i).quantity = 1;
            elseif D(n)
                Formula(i).quantity = str2num(num{num_counter});                 %#ok<*ST2NM>
                n = n+length(num{num_counter});
                num_counter = num_counter+1;
            end
        elseif U(n) && ~L(n+1)
            Formula(i).element = str(n);
            n = n+1;
            if D(n)
                Formula(i).quantity = str2num(num{num_counter});                
                n = n+length(num{num_counter});
                num_counter = num_counter+1;      
            elseif ~D(n)
                Formula(i).quantity = 1;
            end
        end
    elseif U(n)
        Formula(i).quantity = 1;
        Formula(i).element = str(n);
    else
    n = n+1;
    end
end