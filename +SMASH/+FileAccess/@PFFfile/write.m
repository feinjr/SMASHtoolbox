% write Write data to a PFF object
%
% UNDER CONSTRUCTION!
%
% See also PFFfile
%

%
% 
%
function write(object,data,mode)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isstruct(data) && (numel(data)==1),...
    'ERROR: data must be passed in an individual structure');

dataset=struct(...
    'Type','(PFTNGD dataset)','Title','(Default title)');
dataset.Grid={};
dataset.GridLabel={};
dataset.Vector={};
dataset.VectorLabel={};
name=fieldnames(data);
for k=1:numel(name)
    if isfield(dataset,name{k})
        dataset.(name{k})=data.(name{k});
    else
        fprintf('Ignoring unrecognized field "%s"\n',name{k});
    end
end

if (nargin<3) || isempty(mode)
    mode='create';
end
assert(ischar(mode),'ERROR: invalid mode requested')
mode=lower(mode);
switch mode
    case {'create','append','overwrite'}
        % do nothing
    otherwise
        error('ERROR: invalid mode requested');
end

% verify dataset
M=numel(dataset.Grid);
N=numel(dataset.Vector);
NX=nan(1,M);
for k=1:M
    NX(k)=numel(dataset.Grid{k});
end
for k=1:N
    assert(numel(dataset.Vector{k})==prod(NX),...
        'ERROR: inconsistent array size detected');
end

if isempty(dataset.GridLabel)
    dataset.GridLabel=cell(1,M);
    for k=1:M
        dataset.GridLabel{k}=sprintf('(Grid #%d label)',k);
    end
end
assert(numel(dataset.GridLabel)==M,...
    'ERROR: inconsistent number of grid labels');

if isempty(dataset.VectorLabel)
    dataset.VectorLabel=cell(1,N);
    for k=1:N
        dataset.VectorLabel{k}=sprintf('(Vector #%d label)',k);
    end
end
assert(numel(dataset.VectorLabel)==N,...
     'ERROR: inconsistent number of vector labels');

% create file handle
switch mode
    case 'create'
       if exist(object.FullName,'file')
            error('ERROR: file already exists');
       end
       fid=fopen(object.FullName,'w+','ieee-be');
    case 'overwrite'
        fid=fopen(object.FullName,'w+','ieee-be');
    case 'append'
        fid=fopen(object.FullName,'r+','ieee-be');
end
CleanObject=onCleanup(@() fclose(fid)); % automatically close on exit

% write file header
DEFAULT=-3;
resetFile(fid);
WriteWord(fid,-4); % FFRAME
WriteWord(fid,repmat(DEFAULT,[1 15]));

% skip existing datasets in append mode
if strcmp(mode,'append')
    resetFile(fid);
    while true
        start=ftell(fid);
        DFRAME=ReadWord(fid);
        if DFRAME == -1 % start word
            LDS=ReadLong(fid);
            fseek(fid,start+2*LDS,'bof'); % move to next dataset
        elseif DFRAME == -2 % stop word
            fseek(fid,-2,'cof'); % move back one word
            break
        else
            error('ERROR: existing dataset problem detected');
        end
    end
    resetFile(fid);
end

% create dataset header
resetFile(fid);
start=ftell(fid);
WriteWord(fid,-1); % DFRAME (start word)
WriteLong(fid,0); % LDS placeholder
WriteWord(fid,7); % TRAW (PFTNGD)
WriteWord(fid,DEFAULT); % VDS
WriteWord(fid,3); % TAPP
WriteWord(fid,1); % RFU
WriteWord(fid,repmat(DEFAULT,[1 9])); % RFU
WriteString(fid,dataset.Type);
WriteString(fid,dataset.Title);

% create dataset
WriteWord(fid,M); % space dimensionality
WriteWord(fid,N); % vector dimensionality
WriteWord(fid,NX);
WriteIntegerArray(fid,DEFAULT);
for k=1:M
    WriteString(fid,dataset.GridLabel{k});
end
for k=1:N
    WriteString(fid,dataset.VectorLabel{k});
end
for k=1:M
    WriteFloatArray(fid,dataset.Grid{k});
end
for k=1:N
    temp=dataset.Vector{k};
    temp=transpose(temp);
    WriteFloatArray(fid,temp);
end

% finish dataset and revise the header
stop=ftell(fid);
WriteWord(fid,-2); % stop word
ftell(fid);
fseek(fid,start+2,'bof'); % move to LDS location
LDS=stop-start;
%fprintf('LDS=%g bytes, %g words\n',LDS,LDS/2);
WriteLong(fid,LDS/2); % LDS (words)
% leave file header "broken"

end