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
%function [result,frequency]=analyze(object,target_function,boundary)
function [result,frequency]=analyze(object,varargin)

% manage options
option.TargetFunction=[];
option.Boundary=[];
option.Normalization='global';
option.DataScale='dB';

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(isfield(option,name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch name
        case 'TargetFunction'
            if ischar(value)
                value=str2func(value);
            end
            assert(isa(value,'function_handle'),...
                'ERROR: invalid TargetFunction')            
        case 'Boundary'
            if isnumeric(value)
                try
                    value=object.Boundary.Children{value};
                catch
                    error('ERROR: invalid boundary index');
                end
            end
            assert(isa(value,'SMASH.ROI.BoundingCurve'),...
                'ERROR: invalid Boundary');
        case 'Normalization'
            assert(ischar(value),'ERROR: invalid Normalization');
            value=lower(value);
            switch value
                case {'global','none'}
                    % do nothing
                otherwise
                    error('ERROR: invalid Normalization');
            end
        case 'DataScale'
            assert(ischar(value),'ERROR: invalid DataScale');
            value=lower(value);
            switch value
                case {'linear','log','dB'}
                    % do nothing
                otherwise
                    error('ERROR: invalid Normalization');
            end            
    end
    option.(name)=value;
end

% perform analysis
frequency=[];
local=object;
local.Preview=[];
localSize=object.Partition.Points;
local.Grid=transpose(1:localSize);
local.Data=zeros(localSize,1);
local=limit(local,'all');

[~,~,FFToption,downsample]=fft(local,local.FFToptions);
if downsample
    warning('SMASH:FFTdownsample',...
        'Downsampling saves memory but may be slow');
end
%option.SpectrumType='power';
%option.FrequencyDomain='positive';

if ~isempty(option.Boundary)
    [x,~,~]=probe(option.Boundary);
    object=limit(object,[min(x) max(x)]);
end

frequency=[];
    function output=local_function(time,signal)
        local.Grid=time;
        local.Data=signal;
        [frequency,output]=fft(local,FFToption);
        if isempty(option.Boundary)
            keep=true(size(output));
        else
            center=(time(end)+time(1))/2;
            [xmin,xmax]=probe(option.Boundary,center);
            keep=(frequency>=xmin) & (frequency<=xmax);
        end
        if isempty(option.TargetFunction)
            output(~keep)=nan;
        else
            frequency=frequency(keep);
            output=output(keep);
            output=feval(option.TargetFunction,frequency,output);
        end  
    end
result=analyze@SMASH.SignalAnalysis.ShortTime(object,@local_function);

if isempty(option.TargetFunction)
    if isreal(result.Data)
        result=SMASH.ImageAnalysis.Image(...
            result.Grid,transpose(frequency),transpose(result.Data));     
        result.DataScale=option.DataScale;
    else
        temp=transpose(result.Data);
        temp=repmat(temp,[1 1 2]);
        temp(:,:,1)=real(temp(:,:,1));
        temp(:,:,2)=imag(temp(:,:,2));
        result=SMASH.ImageAnalysis.ImageGroup(...
            result.Grid,transpose(frequency),temp);        
        result.DataScale='linear';
    end
    result.GraphicOptions.YDir='normal';
    result.Grid1Label='Time';
    result.Grid2Label='Frequency';
    switch option.Normalization
        case 'none'
            % do nothing
        case 'global'
            temp=abs(result.Data);
            result.Data=result.Data/max(temp(:));
    end    
else
    % use SignalGroup object as is
end

end