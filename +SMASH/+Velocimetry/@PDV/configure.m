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
        case 'rmsnoise'
            assert(isnumeric(value) && isscalar(value) && value>0,...
                'ERROR: invalid RMSnoise value');
            object.Settings.NoiseAmplitude=value;                               
        %% FFT options
        case 'window'
            object.Measurement.FFToptions.Window=value;
        case 'numberfrequencies'
            object.Measurement.FFToptions.NumberFrequencies=value;
        case 'removedc'
            object.Measurement.FFToptions.RemoveDC=value;       
        %% partition configuration
        case 'partition'
            object=partition(object,value{1},value{2});
        case {'block','blocks'}
            assert(isnumeric(value) & any(numel(value)==[1 2]),...
                'ERROR: invalid block setting');
            if isscalar(value)
                value(2)=0;
            end
            object=partition(object,'block',value);        
        case {'duration','durations'}
            assert(isnumeric(value) & any(numel(value)==[1 2]),...
                'ERROR: invalid duration setting');
            if isscalar(value)
                value(2)=value(1);
            end
            object=partition(object,'duration',value);        
        case {'point','points'}
            assert(isnumeric(value) & any(numel(value)==[1 2]),...
                'ERROR: invalid Points setting');
            if isscalar(value)
                value(2)=value(1);
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