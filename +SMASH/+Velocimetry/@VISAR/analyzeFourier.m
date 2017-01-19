% ANALYZEFOURIER - Analyze a VISAR signal in Fourier Space
%
% This method analyzes a VISAR signal in Fourier Space.  The syntax is 
% below: 
%
% object=analyzeFourier(object,'Points',N,'Window',window,'Filter',filter)
%
% Points is used to define the number of points for the FFT.  It will 
% always be the next power of two from the number specified for speed.  If
% no value for points is specified, the FFT is performed on the next power
% of 2 above the number of data points
%
% The window is used prior to the FFT to the data.  This follows that
% syntax of the FFT method for signal objects.  The default window is 
% boxcar.  
%
% The filter parameter is used to remove high frequency noise before 
% transforming back into the time domain.  There are two options:
%     'Guassian' or'Gauss' - This is the default
%     'Tukey'
% Each filter option can be specified as a cell array.  The cell array 
% option allows one to specify the low pass filter parameters.  The options
% are below:
%      {'Gaussian',frequency} - This is the default.  Frequency specifies
%                               the frequency correspondig to 10% 
%                               transmission (0.1 factor).  The default is 
%                               the inverse of 10x the delay (0.01/tau). 
%      {'Tukey, freq1, freq2} - Frequency 1 specifies the freqquncy cutoff
%                               for full transmission (1 factor).  
%                               Frequency 2 specifies frequency cutoff for 
%                               no transmission (0 factor).  If Frequency 2
%                               is not specified, this becomes a 
%                               rectangular filter.  The default for
%                               frequency 1 is (0.01/tau) and for frequency
%                               2 (0.03/tau).  
%
% created October 27, 2016 by Paul Specht (Sandia National Laboratories)
% modified January 19, 2017 by Paul Specht (Sandia National Laboratories)

function object=analyzeFourier(varargin)

%% manage the input
object=varargin{1};
object=process(object);
%set the default values
N=length(object.FringeShift.Grid);
tau=object.Wavelength/(2*(1+object.Dispersion)*object.VPF);
L=[0.01/tau,0];
window='None';
filter='Gauss';
if nargin > 1
    counter=2;
    while counter < nargin
        switch lower(varargin{counter})
            case 'points'
                if isnumeric(varargin{counter+1})
                    N=round(abs(varargin{counter+1}(1)));
                else
                    error('ERROR: Number of Frequency Points must be Numeric');
                end
            case 'window'
                window=varargin{counter+1};
            case 'filter'
                if ischar(varargin{counter+1})
                    filter=varargin{counter+1};
                    switch lower(filter)
                        case {'gaussian','gauss'}
                        case 'tukey'
                            L=[0.01/tau,0.03/tau];
                        otherwise
                            error('ERROR: Invalid Filter Designation');
                    end
                elseif iscell(varargin{counter+1})
                    assert(ischar(varargin{counter+1}{1}),...
                        'ERROR: Invalid Filter Designation');
                    filter=varargin{counter+1}{1};
                    switch lower(varargin{counter+1}{1})
                        case {'gaussian','gauss'}
                            assert(isnumeric(varargin{counter+1}{2}),...
                                'ERROR: Invalid Filter Designation');
                            L(1)=abs(varargin{counter+1}{2}(1));
                        case 'tukey'
                            assert(isnumeric(varargin{counter+1}{2}),...
                                'ERROR: Invalid Filter Designation');
                            if length(varargin{counter+1}) == 2
                                L(1)=abs(varargin{counter+1}{2}(1));
                                L(2)=L(1);
                            else
                                assert(isnumeric(varargin{counter+1}{3}),...
                                    'ERROR: Invalid Filter Designation');
                                L(1)=abs(varargin{counter+1}{2}(1));
                                L(2)=abs(varargin{counter+1}{3}(1));
                            end                   
                        otherwise
                            error('ERROR: Invalid Filter Designation');
                    end
                else
                    error('ERROR: Invalid Filter Designation');
                end
            otherwise
                error('ERROR: Invalid Input Parameter');
        end
        counter=counter+2;
    end
end

option=struct('Window',window,...
    'RemoveDC',false,'NumberFrequencies',[N inf],...
    'SpectrumType','complex','FrequencyDomain','positive');

%% transform to frequency domain
%fringe shift
[f,G]=fft(object.FringeShift,option);
%transfer function
x=2*pi*1i;
e=exp(-x*tau*f);
T=(x*f)./(1-e+x.*object.Dispersion.*tau.*f.*e);
%correct value at zero frequency using l'Hopital's rule
[~,m]=min(abs(f));
if f(m) == 0
    T(m)=x/(x*tau+x*tau*object.Dispersion);
end
%apply the filter to remove high frequency noise
switch lower(filter)
    case {'gaussian','gauss'}
        s=sqrt(-(L(1)^2)/(2*log(0.1)));
        F=exp(-(f.^2)/(2*s^2));
    case 'tukey'
        startf=sum(f <= L(1));
        endf=sum(f <= L(2));
        if endf <= startf
            F=[ones(startf,1);zeros(length(f)-startf,1)];
        else
            tukey=0.5*(1+cos(pi*(f(startf+1:endf)-L(1))/(L(2)-L(1))));
            F=[ones(startf,1);tukey;zeros(length(f)-endf,1)];
        end
    otherwise
        error('ERROR: Invalid Filter Parameter');
end

%calcualte velocity in frequency domain
V=(object.Wavelength/2).*G.*T.*F;

%% transform back to time domain
v=ifft(V,2*length(V),'symmetric');
v=ifftshift(v);
%trim off zero-padding
trimval=length(v)-length(object.FringeShift.Grid);
v=v(ceil(0.5*trimval)+1:length(v)-floor(0.5*trimval));
%parseval's scaling
area1=2*trapz(f,V.*conj(V));
area2=trapz(object.FringeShift.Grid,v.*conj(v));
v=v*sqrt(area1/area2);

%% Save results
object.Velocity=SMASH.SignalAnalysis.Signal(object.FringeShift.Grid,v);
object.Displacement=integrate(object.Velocity);





