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
%     [value,index]=max(power);
%     location=frequency(index);
%     out=[location; value];
%     end
% The "result" object still a
%
% See also STFT, partition, preview, tract, ImageAnalysis.Image
%

%
% created November 12, 2014 by Daniel Dolan
%
function [result,frequency]=analyze(object,target_function)

% handle input
if nargin<2
    target_function=[];
elseif ischar(target_function)
    target_function=str2func(target_function);
else
    assert(isa(target_function,'function_handle'),'ERROR: invalid target function');
end

% check boundaries
boundary=[];
if ~isempty(object.Boundary)
    if numel(object.Boundary)>1
        fprintf('All boundaries except the first will be ignored\n');
    end
    boundary=object.Boundary{1};
    
end

% perform analysis
frequency=[];
local=object;
local.Preview=[];
localSize=object.Partition.Points;
local.Grid=transpose(1:localSize);
local.Data=zeros(localSize,1);
local=limit(local,'all');
option=convert(local.FFToptions);
option{end+1}='FrequencyDomain';
option{end+1}='positive';
option{end+1}='SpectrumType';
option{end+1}='power';
[~,~,option,downsample]=fft(local,option{:});
if downsample
    warning('SMASH:FFTdownsample','Downsampling saves memory but may be slow');
end
option.SpectrumType='power';
option.FrequencyDomain='positive';

if isempty(object.Boundary)
    boundary=[];
else
    boundary=object.Boundary{1};
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
    result=SMASH.ImageAnalysis.Image(...
        result.Grid,transpose(frequency),transpose(result.Data));
    %result.YDir='normal';
    result.DataScale='dB';
    result.Grid1Label='Time';
    result.Grid2Label='Frequency';
    temp=max(result.Data(:));
    switch object.Normalization
        case 'none'
            % dBm?
        otherwise
            result.DataLim=[-60 0];
            result.Data=result.Data/max(temp(:));
    end
else
    
end

end