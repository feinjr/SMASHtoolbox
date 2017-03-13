% configure Configure TIPC analysis settings
%
% This method configures analysis settings in a NTOF object.
% To see the current settings:
%     >> configure(object); % reveal settings
% Settings are changed by passing name/value pairs into the method and
% using an output.
%     >> object=configure(object,name,value,...); % modify settings in current object
%     >> new=configure(object,name,value,...); % modified settings stored in new object
%
% See also TIPC
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
    % print TIPC settings
    fprintf('*** TIPC analysis settings ***\n');
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
        case {'shot', 'shotnumber', 'shot number'} 
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: shot number must be scalar integer');
            object.Settings.Shot=value;

        case {'numberimages', 'n images', 'nimages', 'number images', 'number of images'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Number of images must be scalar integer');
            object.Settings.NumberImages=value;
            
        case {'nslices', 'n slices', 'number of slices'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Number of slices must be scalar integer');
            object.Settings.Nslices=value;
            
        case {'referenceimage', 'ref','reference image'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Reference image index must be scalar integer');
            object.Settings.ReferenceImage=value;
            
        case {'decaytime', 'decay time'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Decay time must be scalar numeric value');
            object.Settings.DecayTime=value;
            
        case {'pinholediameter', 'pinhole','pinhole diameter'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Pinhole diameter must be scalar numeric value');
            object.Settings.PinholeDiameter=value;
            
        case {'pinholetodetectordistance', 'pinhole to detector distance', 'pinhole to detector', 'pinholetodetector'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Pinhole-to-Detector distance must be scalar numeric value');
            object.Settings.PinholetoDetectorDistance =value;
            object.Settings.Magnification = ...
                object.Settings.PinholetoDetectorDistance/object.Settings.SourcetoPinholeDistance;
            
        case {'sourcetopinholedistance', 'source to pinhole distance', 'source to pinhole', 'sourcetopinhole'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Source-to-Pinhole distance must be scalar numeric value');
            object.Settings.SourcetoPinholeDistance =value;
            object.Settings.Magnification = ...
                object.Settings.PinholetoDetectorDistance/object.Settings.SourcetoPinholeDistance;
        case 'filters'
            assert(isstruct(value), ...
                'ERROR: Filter property must be a structure');
            fnames = fieldnames(value);
            assert(strcmp(fnames{1},'Material') && strcmp(fnames{2},'Thickness'),...
                'ERROR: Filter structure must have fields "Material" and "Thickness"');
            
            assert(numel(fieldnames(value.(fnames{1}))) == numel(fieldnames(value.(fnames{2}))), ...
                'ERROR: Material and Thickness fields must have same number of elements');
            
            object.Settings.Filters = value;
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