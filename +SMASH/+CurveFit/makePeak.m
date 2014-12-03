% makePeak Generate a peak function handle by name.
%
% This function generates function handles for a named peak function.
%     >> G=makePeak(name);
% Valid names are 'gaussian', 'lorentzian', 'pseudo-voigt','square',
% 'triangle', and 'voigt' (case insenstive).
%
% The handles generated by this function accept two inputs, i.e. G=G(p,x).
% The first input is a parameter array, the second input is an array of
% locations where the function is evaluated.  The parameter array size and
% interpretation depends on the peak name.
%     Gaussian peaks require two parameters: [x0 sigma]
%     Lorentzian peaks require two parameters: [x0 gamma]
%     Pseudo-Voigt peaks require three parameters: [x0 gamma weight]
%     Square peaks require two parameters: [x0 Lx]
%     Triangle peaks require two parameters: [x0 Lx]
%     Voigt peaks require three parameters: [x0 sigma gamma]
% Parameters must be passed each time the function handle is used.
%     >> G=makePeak('gaussian');
%     >> x=linspace(-5,5,1000);
%     >> plot(x,G([0 1],x); % x0=0, sigma=1
%     >> plot(x,G([1 2],x); % x0=1, sigma=2
% The position parameter (x0) can take on any value, but width parameters
% (sigma, gamma, and Lx) must always be greater than zero. Width parameters
% should generally be >1% of the total evaluation range.
%
% For Voigt peaks, extreme width differences can lead to slow or unexpected
% results.  When gamma >> sigma, the peak is nearly Lorentzian and the
% Voigt shape should be avoided (NaN entries may be encountered).  When
% sigma >> gamma, the peak is nearly Gaussian and once again the Voigt
% shape should be avoided (evaluation becomes extremely slow).  The
% computational overhead of the Voigt shape is largely wasted if the width
% width parameters differ by more than 2-3 orders of magnitude.
%
% By default, error checking (number of inputs, number of parameters, etc.)
% is performed every time the peak function handle is called.  Error checks
% can be bypassed to speed up repetitive function calls.
%     >> G=makePeak(name,'bypass');
%
% See also CurveFit

%
% created December 2, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function out=makePeak(name,errtest)

% handle input
assert(nargin>=1,'ERROR: no peak name specified');
assert(ischar(name),'ERROR: invalid peak name');

if nargin<2
    errtest='';
end
if strcmpi(errtest,'bypass')
    errtest=false;
else
    errtest=true;
end

% process request
switch lower(name)
    case 'gaussian'
        out=@gaussian;
    case 'lorentzian'
        out=@lorentzian;
    case {'pseudo-voigt','pseudo_voigt'}
        out=@pseudo_voigt;
    case 'square'
        out=@square;
    case 'triangle'
        out=@triangle;
    case 'voigt'              
        out=@voigt;
    otherwise
        error('ERROR: invalid peak name');
end
%%
    function y=gaussian(param,x) % [x0 sigma]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==2,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
        end
        x0=param(1);
        sigma=param(2);
        y=exp(-(x-x0).^2/(2*sigma^2));        
    end

%%
    function y=lorentzian(param,x) % [x0 gamma]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==2,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
        end
        x0=param(1);
        gamma=param(2);
        y=(x-x0)/gamma;
        y=1./(1+y.^2);
        
    end
%%
    function y=pseudo_voigt(param,x) % [x0 gamma w]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==3,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
            assert(param(3)>=0 & param(3)<=1,'ERROR: invalid weight parameter');
        end
        L=lorentzian(param(1:2),x);
        sigma=param(2)/sqrt(2*log(2));
        G=gaussian([param(1) sigma],x);
        w=param(3);
        y=w*L+(1-w)*G;
    end
%%
    function y=square(param,x) % [x0 Lx]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==2,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
        end
        x0=param(1);
        Lx=param(2);
        y=zeros(size(x));
        index=abs(x-x0)<(Lx/2);
        y(index)=1;
        
    end
%%
    function y=triangle(param,x) % [x0 Lx]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==2,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
        end
        x0=param(1);
        Lx=param(2)/2;       
        y=zeros(size(x));
        slope=1/Lx;
        index=(x>(x0-Lx)) & (x<=x0);
        y(index)=1+slope*(x(index)-x0);
        slope=-slope;
        index=(x>x0) & (x<(x0+Lx));
        y(index)=1+slope*(x(index)-x0);
    end
%% 
    function y=voigt(param,x) % [x0 sigma gamma]
        if errtest
            assert(nargin==2,'ERROR: invalid number of inputs');
            assert(numel(param)==3,'ERROR: invalid number of parameters');
            assert(param(2)>0,'ERROR: invalid width parameter');
            assert(param(3)>0,'ERROR: invalid width parameter');
        end
        % access parameters
        x0=param(1);
        sigma=param(2);
        gamma=param(3);
        % apply normalization
        L=max(x)-min(x);
        L=max(L,sigma);
        L=max(L,gamma);        
        sigma=sigma/L;
        gamma=gamma/L;
        % integration
        u=(x-x0)/L;
        kernel=@(v) exp(-v.^2/(2*sigma^2))./(1+(u-v).^2/gamma^2);
        y=integral(kernel,-inf,+inf,'ArrayValued',true);        
        u=0;
        kernel=@(v) exp(-v.^2/(2*sigma^2))./(1+(u-v).^2/gamma^2);
        y=y/integral(kernel,-inf,+inf);
    end

end
