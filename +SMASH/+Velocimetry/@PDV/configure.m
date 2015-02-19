% configure Configure analysis settings
%
% This method configures analysis settings in a PDV object.  These settings
% fall into three categories: FFT, partition, and PDV.  To see the current
% settings:
%     >> configure(object); % reveal settings
% Settings are changed by passing name/value pairs into the method and
% using an output.
%     >> object=configure(object,name,value,...); % modify settings in current object
%     >> new=configure(object,name,value,...); % modified settings stored in new object
%
% See also PDV
%

%
% created February 19, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=configure(object,varargin)

Narg=numel(varargin);

% reveal configuration
if nargout==0
    if Narg>0
        warning('SMASH:PDV','Configuration changes ignored in reveal mode');
    end
    % determine label format    
    name=fieldnames(object.Settings);
    L=max(cellfun(@numel,name));
    name=fieldnames(object.Settings);
    L=max(L,max(cellfun(@numel,name)));
    name=fieldnames(object.Measurement.Partition);
    L=max(L,max(cellfun(@numel,name)));
    format=sprintf('\t%%%ds : ',L);
    fprintf('\n');
    % print FFT options
    fprintf('** FFT settings **\n');
    name=properties(object.Measurement.FFToptions);
    for k=1:numel(name);
        fprintf(format,name{k});
        printValue(object.Measurement.FFToptions.(name{k}));
        fprintf('\n');
    end
     % print partition setttings
    fprintf('** Partition settings **\n');
    name=fieldnames(object.Measurement.Partition);
    for k=1:numel(name);
        fprintf(format,name{k});
        printValue(object.Measurement.Partition.(name{k}));
        fprintf('\n');
    end
    % print PDV settings
    fprintf('** Analysis settings **\n');
    name=fieldnames(object.Settings);    
    for k=1:numel(name);
        fprintf(format,name{k});
        printValue(object.Settings.(name{k}));
        fprintf('\n');
    end   
    fprintf('\n');
    return
end

% process configuration changes
if Narg==0
    fprintf('Interactive configuration is not ready yet...\n');
end
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid setting name');
    value=varargin{n+1};
    switch lower(name)
        % PDV settings
        case 'wavelength'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid Wavelength value');
            object.Settings.Wavelength=value;
        case 'referencefrequency'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid ReferenceFrequency value');
            object.Settings.ReferenceFrequency=value;
        case 'bandwidth'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid BandWidth value');
            object.Settings.Bandwidth=value;
        case 'noiseregion'
            assert(isnumeric(value) && (numel(value)==4),...
                'ERROR: invalid NoiseRegion value');
            object.Settings.NoiseRegion=reshape(value,[1 4]);
        case 'uniquetolerance'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid UniqueTolerance value');
            object.Settings.UniqueTolerance=value;
        case 'boundary'
            error('ERROR: use the "bound" method instead of "configure"');
        case 'convertfunction'
            if ischar(value)
                value=str2func(value);
            end
            assert(isa(value,'function_handle') | isempty(value),...
                'ERROR: invalid ConvertFunction value');
            object.Settings.ConvertFunction=value;
        case 'harmonicfunction'
            if ischar(value)
                value=str2func(value);
            end
            assert(isa(value,'function_handle') | isempty(value),...
                'ERROR: invalid HarmonicFunction value');
            object.Settings.HarmonicFunction=value;
        % FFT options
        case 'window'
            object.Measurement.FFToptions.Window=value;
        case 'numberfrequencies'
            object.Measurement.FFToptions.NumberFrequencies=value;
        case 'removedc'
            object.Measurement.FFToptions.RemoveDC=value;
        case 'frequencydomain'
            object.Measurement.FFToptions.FrequencyDomain=value;
        case 'spectrumtype'
            object.Measurement.FFToptions.SpectrumType=value;
        % partition configuration
        case 'partition'
            try
                object.Measurement=...
                    partition(object.Measurement,value{1},value{2});
            catch
                error('ERROR: invalid partition value');
            end
        otherwise
            error('ERROR: "%s" is an invalid setting');            
    end
end
varargout{1}=object;

end

function printValue(value)

if isnumeric(value) || islogical(value)
    format='%.6g ';
    if isscalar(value)
        fprintf(format,value);
    elseif numel(value)<10
        fprintf('[');
        fprintf(format,value);
        fprintf('\b]');
    else
        temp=size(value);
        temp=sprintf('%dx',temp);
        temp=temp(1:end-1);
        fprintf('[%s %s]',temp,class(value));
    end
elseif ischar(value)
    fprintf('''%s''',value);
elseif iscell(value) || isstruct(value);
    temp=size(value);
    temp=sprintf('%dx',temp);
    temp=temp(1:end-1);
    fprintf('[%s %s]',temp,class(value));
else
    fprintf('[%s]',class(value));
end

end