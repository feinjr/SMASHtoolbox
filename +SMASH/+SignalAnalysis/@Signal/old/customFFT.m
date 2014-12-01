% customFFT 
%
function varargout=customFFT(signal,time,varargin)

% settings from previous call
persistent default
if isempty(default)
    default=struct('WindowName','Hann','Window',[],'RemoveDC',true,...
        'NumberFrequencies',[64 inf]);
end
persistent previous
if isempty(previous)
    previous=default;
end

%% handle input
Narg=numel(varargin);
if (Narg==1) && strcmpi(varargin{1},'previous')    
    options=previous;
    Narg=0;
elseif rem(Narg,2)==0
    options=default;
else
    error('ERROR: unmatched name/value pair');    
end

for n=1:2:Narg
    name=varargin{n};
    %if ~isfield(options,name)
    %    error('ERROR: %s is an invalid option name',name);
    %end
    value=varargin{n+1};
    if isempty(value)
        value=default.(name);          
    end
    options.(name)=value;
end

%% verify options
numpoints=numel(signal);

if ischar(options.Window)
    options.WindowName=options.Window;
    options.Window=[];
end
if isempty(options.Window)
    arg=0:(numpoints-1);
    arg=arg/(numpoints-1);
    switch lower(options.WindowName)
        case 'gaussian'
            sigma=numpoints/6; % Three deviations (both directions)
            mid=(arg(end)+arg(0))/2;
            options.Window=exp(-(arg-mid).^2/(2*sigma^2));
        case 'hamming'
            options.Window=0.54-0.46*cos(2*pi*arg);
        case {'hann','hanning'}
            options.Window=0.50-0.50*cos(2*pi*arg);
        case 'blackman'
            options.Window=0.42-0.50*cos(2*pi*arg)+0.08*cos(4*pi*arg);
        case 'kaiser'
            beta=sqrt(3)*pi; % match Hamming window lobe width
            %beta=2*sqrt(2*pi); % match Blackman window lobe width
            arg=sqrt(1-(2*arg-1).^2);
            options.Window=besseli(0,beta*arg)/besseli(0,beta);
        case {'boxcar','rectangle','flat','none'}
            options.Window=ones(size(arg));
        otherwise
            error('ERROR: unknown window (''%s'') specified',options.WindowName);
    end
end
if numel(options.Window)==numpoints
    options.Window=options.Window(:);
else 
    error('ERROR: window and signal sizes are not consistent');
end

if ~islogical(options.RemoveDC)
    error('ERROR: invalid RemoveDC setting');
end

value=options.NumberFrequencies;
if ~isnumeric(value) || any(value~=round(value)) || any(value<1)
    error('ERROR: invalid NumberFrequencies setting');
elseif (numel(value)==1) && ~isinf(value)
    options.NumberFrequencies(end+1)=inf;
elseif (numel(value)==2) && (value(2)>=value(2))
else
    error('ERROR: invalid NumberFrequencies setting');
end

%% calculate spectrum
T=(time(end)-time(1))/(numpoints);
N2A=pow2(nextpow2(numpoints));
%N2B=pow2(nextpow2(2*options.NumberFrequencies(1)));
N2B=pow2(nextpow2(2*(options.NumberFrequencies(1)-1)));
N2=max(N2A,N2B);
N2=pow2(nextpow2(N2));
m=0:(N2/2);
frequency=m/(N2*T);
frequency=frequency(:);

signal=signal.*options.Window;
transform=fft(signal,N2);
transform=transform(m+1);
power=real(transform.*conj(transform));
if nargout>=3
    phase=unwrap(atan2(imag(transform),real(transform)));
end

previous=options;

%% downsample as needed
if numel(frequency)>options.NumberFrequencies(2)
    f=linspace(0,max(frequency),options.NumberFrequencies(2));
    power=EAinterp(frequency,power,f);
    phase=EAinterp(frequency,phase,f);
    frequency=f;
end

%% handle output
if nargout==0
    figure;  
    output=10*log10(power);
    plot(frequency,output);
    xlabel('Frequency')
    ylabel('Power (dB scale)');
end

if nargout>=1
    varargout{1}=frequency;
end

if nargout>=2
    varargout{2}=power;
end

if nargout>=3
    varargout{3}=phase;
end

end