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
% revised April 6, 2015 by Daniel Dolan
%   -allow direct modifications to partition parameters
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
    try
        name=fieldnames(object.Measurement.Partition);
        L=max(L,max(cellfun(@numel,name)));   
    catch
        % do nothing
    end
    format=sprintf('\t%%%ds : ',L);
    fprintf('\n');
    % print partition setttings
    fprintf('*** Partition settings ***\n');
    if isempty(object.Measurement.Partition)
        fprintf('\t (undefined)\n');
    else
        name=fieldnames(object.Measurement.Partition);
        name=sort(name);
        for k=1:numel(name);
            fprintf(format,name{k});
            printValue(object.Measurement.Partition.(name{k}));
            fprintf('\n');
        end                
    end
    % print FFT options
    fprintf('*** FFT settings ***\n');
    name=properties(object.Measurement.FFToptions);
    name=sort(name);
    for k=1:numel(name)
        if strcmpi(name{k},'FrequencyDomain') || strcmpi(name{k},'SpectrumType')
            continue
        end
        fprintf(format,name{k});
        printValue(object.Measurement.FFToptions.(name{k}));
        fprintf('\n');
    end   
    % print PDV settings
    fprintf('*** Analysis settings ***\n');
    name=fieldnames(object.Settings);
    name=sort(name);
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
        %% PDV settings
        case 'wavelength'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid Wavelength value');
            object.Settings.Wavelength=value;
        case 'referencefrequency'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid ReferenceFrequency value');
            object.Settings.ReferenceFrequency=value;
        case 'noiseamplitude'
            assert(isnumeric(value) && isscalar(value) && value>0,...
                'ERROR: invalid NoiseAmplitude value');
            object.Settings.NoiseAmplitude=value;           
        case 'uniquetolerance'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid UniqueTolerance value');
            object.Settings.UniqueTolerance=value;
%         case 'convertfunction'
%             if ischar(value)
%                 value=str2func(value);
%             end
%             assert(isa(value,'function_handle') | isempty(value),...
%                 'ERROR: invalid ConvertFunction value');
%             object.Settings.ConvertFunction=value;
        case 'analysismode'
            assert(ischar(value),'ERROR: invalid AnalysisMode value');
            switch lower(value)
                case 'centroid'
                    object.Settings.AnalysisMode='centroid';
                    object.Measurement.FFToptions.SpectrumType='power';
                case 'fit'
                    object.Settings.AnalysisMode='fit';
                    object.Measurement.FFToptions.SpectrumType='complex';
                otherwise
                    error('ERROR: %s is an invalid AnalysisMode');
            end
        case 'harmonicfunction'
            if ischar(value)
                value=str2func(value);
            end
            assert(isa(value,'function_handle') | isempty(value),...
                'ERROR: invalid HarmonicFunction value');
            object.Settings.HarmonicFunction=value;
        case 'shocktable' % [index start stop]
            if isempty(value)
                object.Settings.ShockTable=[];
                return
            end
            assert(size(value,2)==3,'ERROR: invalid ShockTable value');
            object.Settings.ShockTable=value;
        %% FFT options
        case 'window'
            object.Measurement.FFToptions.Window=value;
        case 'numberfrequencies'
            object.Measurement.FFToptions.NumberFrequencies=value;
        case 'removedc'
            object.Measurement.FFToptions.RemoveDC=value;
        %case 'frequencydomain'
        %    object.Measurement.FFToptions.FrequencyDomain=value;
        %case 'spectrumtype'
        %    object.Measurement.FFToptions.SpectrumType=value;
        %    switch lower(object.Measurement.FFToptions.SpectrumType)
        %        case 'power'
        %            object.Settings.AnalysisMode='centroid';
        %        case 'complex'
        %            object.Settings.AnalysisMode='fit';
        %    end
        %% partition configuration
        case 'partition'
            object=partition(object,value{1},value{2});
        case {'block','blocks'}
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid block setting');
            try
                value(2)=object.Measurement.Partition.Overlap;
            catch
                value(2)=0;
            end
            object=partition(object,'block',value);
        case 'overlap'
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid overlap setting');            
            value(2)=value(1);
            try
                value(1)=object.Measurement.Partition.Blocks;
            catch
                value(1)=1000;
            end
            object=partition(object,'block',value);
        case {'duration','durations'}
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid duration setting');
            try
                value(2)=object.Measurement.Partition.Advance;
            catch
                value(2)=value(1);
            end
            object=partition(object,'duration',value);
        case 'advance'
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid advance setting');
            value(2)=value(1);
            try
                value(1)=object.Measurement.Partition.Duration;
            catch
                value(1)=value(2);
            end
            object=partition(object,'duration',value);
        case {'point','points'}
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid Points setting');
            try
                value(2)=object.Measurement.Partition.Skip;
            catch
                value(2)=value(1);
            end
            object=partition(object,'points',value);
        case 'skip'
            assert(isnumeric(value) & numel(value)==1,...
                'ERROR: invalid Skip setting');
            value(2)=value(1);
            try
                value(1)=object.Measurement.Partition.Points;
            catch
                value(1)=value(2);
            end
            object=partition(object,'points',value);
        otherwise
            error('ERROR: "%s" is an invalid setting',name);
    end
end
varargout{1}=object;

end

function printValue(value)

if isempty(value)
    % do nothing
elseif isnumeric(value) || islogical(value)
    format='%.6g ';
    if isscalar(value)
        fprintf(format,value);
    elseif (size(value,1)==1) && (numel(value)<10)
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