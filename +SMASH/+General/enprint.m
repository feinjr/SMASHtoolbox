% enprint Print with engineering notation
%
% This function prints a number with engineering notation.
%    result=enprint(number);
% The output "result" displays the number in modified scientific notation.
%   -Exponents are always factors of three.
%   -Mantissa and exponents signs are always displayed.
%   -Three digits are always used for the exponent.
% The default number of mantissa digits is three.  The number of mantissa
% digits can be changed with a second input.
%   result=enprint(number,digits);
% 
% If no output is specified, the formatted result is printed in the command
% window.
%
% See also General
%

%
% created December 3, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=enprint(number,digits)

% manage input
assert(nargin>=1,'ERROR: insufficient input');

assert(isnumeric(number) && isscalar(number),...
    'ERROR: invalid number');

if (nargin<2) || isempty(digits)
    digits=3;
end
assert(isnumeric(digits),'ERROR: invalid digits value');
if isscalar(digits)
    digits(2)=3;
end
assert((numel(digits)==2) && all(digits>0) && all(digits==round(digits)),...
    'ERROR: invalid digits value');
assert(any(digits(2)==[2 3]),'ERROR: invalid digits value');

% process number
if isnan(number) || isinf(number)
    result=sprintf('%+g',number);
else
    if number>=0
        result='+';
    else
        result='-';
    end
    number=abs(number);    
    if number==0
        mantissa=0;
        exponent=0;
    else
        exponent=3*floor(log10(number)/3);
        mantissa=number/(10^exponent);
    end
    
    format=sprintf('%%c%%#.%dgE%%+0%dd',digits(1),digits(2)+1);
result=sprintf(format,result,mantissa,exponent);

end

% manage output
if nargout>0
    varargout{1}=result;
else
    fprintf('%s\n',result);
end

end