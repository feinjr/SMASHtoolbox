% configure Configure NTOF analysis settings
%
% This method configures analysis settings in a NTOF object.
% To see the current settings:
%     >> configure(object); % reveal settings
% Settings are changed by passing name/value pairs into the method and
% using an output.
%     >> object=configure(object,name,value,...); % modify settings in current object
%     >> new=configure(object,name,value,...); % modified settings stored in new object
%
% See also NTOF
%

%
% created January 21, 2016 by Patrick Knapp (Sandia National Laboratories)
%
function varargout=configure(object,varargin)

Narg=numel(varargin);

% reveal configuration
if nargout==0
    if Narg>0
        warning('SMASH:NTOF','Configuration changes ignored in reveal mode');
    end
    % determine label format
    name=fieldnames(object.Settings);
    L=max(cellfun(@numel,name));
    name=fieldnames(object.Settings);
    L=max(L,max(cellfun(@numel,name)));
    format=sprintf('\t%%%ds : ',L);
    % print NTOF settings
    fprintf('*** NTOF analysis settings ***\n');
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
        %% settings
        case 'bangtime'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid bang time value');
            object.Settings.BangTime=value;
        case 'burnwidth'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid burn width value');
            object.Settings.BurnWidth=value;
        case 'lightoutput'
            assert(ischar(value),...
                'ERROR: invalid file name for light output data');
            LO = SMASH.SignalAnalysis.Signal(value,'column');
            object.Settings.LightOutput=LO;
        case 'instrumentresponse'
            assert(ischar(value),...
                'ERROR: invalid file name for instrument response function');
            irf = SMASH.SignalAnalysis.Signal(value,'column');
            object.Settings.InstrumentResponse=irf;
        case 'reaction'
            assert(ischar(value),...
                'ERROR: nuclear reaction string ("DDn", "DT")');
            object.Settings.Reaction=value;
        case 'earray'
            assert(isnumeric(value) && numel(value)==3,...
                'ERROR: Energy Array must have 3 numeric values: [Emin, Emax, N]');
            object.Settings.Earray=value;
        case 'signallimits'
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: Signal limits must have 2 numeric values: [tmin, tmax]');
            object.Settings.SignalLimits=value;
        case 'noiselimits'
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: Noise limits must have 2 numeric values: [tmin, tmax]');
            object.Settings.NoiseLimits=value;
        case 'fitlimits'
            assert(isnumeric(value) && numel(value)==2,...
                'ERROR: Fit limits must have 2 numeric values: [tmin, tmax]');
            object.Settings.FitLimits=value;
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