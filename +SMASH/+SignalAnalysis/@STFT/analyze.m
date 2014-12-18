% ANALYZE Apply local spectral analysis
%
% This method performs local spectra analysis on a STFT object.
%     >> result=analyze(object);
% The output "result" is an Image object containing spectra from the
% partitions of the source object. Analysis parameters are defined by the
% source object's properties (Window, NUmberFrequencies, etc.).
%
% The power spectra generated with this method can be passed to a
% post-processing function (specified as a function handle).
%     >> result=analyze(object,@myfunc);
% The post-processing function must accept two inputs and return its output
% as a column vector.  The following example shows a function that returns
% the location and value of the largest spectral power.
%     function out=myfunc(frequency,power)
%        [value,index]=max(power);
%        location=frequency(index);
%        out=[location; value];
%     end
% The output "result" is a SignalGroup group object.  Each signal in this
% object corresponds to one of the post-processing function's output array.
%
% See also STFT, partition, preview, track, ImageAnalysis.Image,
% SignalAnalysis.SignalGroup
%

%
% created November 12, 2014 by Daniel Dolan
%
function [result,frequency]=analyze(object,target_function,boundary)

% handle input
if (nargin<2) || isempty(target_function)
    target_function=[];
elseif ischar(target_function)
    target_function=str2func(target_function);
else
    assert(isa(target_function,'function_handle'),...
        'ERROR: invalid target function');
end

if (nargin<3) || isempty(boundary)
    boundary=[];
elseif isnumeric(boundary)       
    try
        boundary=object.Boundary.Children{boundary};
    catch
        error('ERROR: invalid boundary index');
    end
else
    assert(isa(boundary,'SMASH.ROI.BoundingCurve'),...
        'ERROR: invalid boundary');
end

% perform analysis
frequency=[];
local=object;
local.Preview=[];
localSize=object.Partition.Points;
local.Grid=transpose(1:localSize);
local.Data=zeros(localSize,1);
local=limit(local,'all');

[~,~,option,downsample]=fft(local,local.FFToptions);
if downsample
    warning('SMASH:FFTdownsample','Downsampling saves memory but may be slow');
end
%option.SpectrumType='power';
%option.FrequencyDomain='positive';

if ~isempty(boundary)
    [x,~,~]=probe(boundary);
    object=limit(object,[min(x) max(x)]);
end

frequency=[];
    function output=local_function(time,signal)
        local.Grid=time;
        local.Data=signal;
        [frequency,output]=fft(local,option);
        if isempty(boundary)
            keep=true(size(output));
        else
            center=(time(end)+time(1))/2;
            [lower,upper]=probe(boundary,center);
            keep=(frequency>=lower) & (frequency<=upper);
        end
        if isempty(target_function)
            output(~keep)=nan;
        else
            frequency=frequency(keep);
            output=output(keep);
            output=feval(target_function,frequency,output);
        end  
    end
result=analyze@SMASH.SignalAnalysis.ShortTime(object,@local_function);

if isempty(target_function)
    if isreal(result.Data)
        result=SMASH.ImageAnalysis.Image(...
            result.Grid,transpose(frequency),transpose(result.Data));
        result=setupResult(result,object);
    else
        temp{1}=SMASH.ImageAnalysis.Image(...
            result.Grid,transpose(frequency),transpose(real(result.Data)));
        temp{2}=SMASH.ImageAnalysis.Image(...
            result.Grid,transpose(frequency),transpose(imag(result.Data)));
        result=temp;
        object.Normalization='none';
        result{1}=setupResult(result{1},object);
        result{2}=setupResult(result{2},object);
    end
    
else
    % nothing to do--superclass method already returns a SignalGroup object
end

end

function result=setupResult(result,object)

result.GraphicOptions.YDir='normal';
%result.DataScale='dB';
result.Grid1Label='Time';
result.Grid2Label='Frequency';
temp=max(result.Data(:));
switch object.Normalization
    case 'none'
        % do nothing
    otherwise
        result.DataLim=[-60 0];
        result.Data=result.Data/max(temp(:));
end

end