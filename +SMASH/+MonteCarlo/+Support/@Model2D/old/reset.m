% reset Reset model function
% 
% This method resets the function associated with a Model2D object.
%     object=reset(object,target,guess);
% Both the function handle ("target") and parameter array ("guess") must be
% specified.  NOTE: all bound information is cleared when the object is
% reset!
%
% See also Model2D
%

%
% created October 27, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,target,guess)

% manage input
assert(nargin==3,'ERROR: invalid number of inputs');

assert(isa(target,'function_handle'),'ERROR: invalid function handle');
assert(isnumeric(guess),'ERROR: invalid guess state');

% assign settings
object.Function=target;
object.Guess=guess(:);
object.NumberParameters=numel(guess);

object.Bounds=repmat([-inf +inf],[object.NumberParameters 1]);
object.Slack=zeros([object.NumberParameters 1]);

object.SlackFunction=cell([object.NumberParameters 1]);
for n=1:object.NumberParameters
    object.SlackFunction{n}=@(q) guess(n)+q;
end

end