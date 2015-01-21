% READ Read dataset from a PFF object
%
% Syntax:
%    >> output=read(object,[dataset]);
% % The optional input (integer) specifies which dataset will read; if
% omitted, the first dataset is read.  The output is a structure that
% depend on the dataset type.
%
% See also PFF, probe, select
%

%
function data=read(object,dataset)

% handle input
if (nargin<2) || isempty(dataset)
    dataset=1;
end

% error checking
table=probe(object);
if (dataset<1) || (dataset~=round(dataset)) || (dataset>numel(table))
    error('ERROR: invalid dataset request');
end

fid=fopen(object.FullName,'r','ieee-be');
CleanObject=onCleanup(@() fclose(fid)); % automatically close file on function exit
ReadWord(fid,16); % skip file header
for k=1:dataset
    % read general header
    start=ftell(fid);
    ReadWord(fid); % DFRAME
    LDS=ReadLong(fid);
    TRAW=ReadWord(fid);
    VDS=ReadWord(fid);
    ReadWord(fid); % TAPP
    ReadWord(fid,10); % RFU
    TYPE=ReadString(fid);
    TITLE=ReadString(fid);
    if k<dataset % skip to next header
        fseek(fid,start+2*LDS,'bof');
        continue
    end
    % read requested dataset
    switch TRAW
        case 0 % PFTDIR
            % these can't be accessed directly
            data=[];
        case 1 % PFTUF3
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTUF3');
                NX=ReadLong(fid);
                NY=ReadLong(fid);
                NZ=ReadLong(fid); %#ok<NASGU>
                ReadWord(fid,5); % skip ISPARE
                X0=ReadFloat(fid);
                DX=ReadFloat(fid);
                Y0=ReadFloat(fid);
                DY=ReadFloat(fid);
                Z0=ReadFloat(fid);
                DZ=ReadFloat(fid);
                temp.XLabel=ReadString(fid);
                temp.YLabel=ReadString(fid);
                temp.DataLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.Data=ReadFloatArray(fid);
                temp.Data=reshape(temp.Data,NX,NY);
                temp.Data=transpose(temp.Data);
                temp.Data=Z0+temp.Data*DZ;
                temp.X=X0+(0:(NX-1))*DX;
                temp.X=temp.X/1000; % convert um to mm
                temp.Y=Y0+(0:(NY-1))*DY;
                temp.Y=temp.Y/1000; % convert um to mm
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end
        case 2 % PFTUF1
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTUF1');
                NX=ReadLong(fid);
                ReadWord(fid,5); % skip ISPARE
                X0=ReadFloat(fid);
                DX=ReadFloat(fid);
                temp.X=X0+(0:(NX-1))*DX;
                temp.X=temp.X(:);
                temp.XLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.Data=ReadFloatArray(fid);
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end
        case 3 % PFTNF3
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTNF3');
                NX=ReadLong(fid); 
                NY=ReadLong(fid); 
                NZ=ReadLong(fid); 
                ReadWord(fid,5); % skip ISPARE
                temp.X=ReadFloatArray(fid);
                temp.Y=ReadFloatArray(fid);
                temp.Z=ReadFloatArray(fid);
                temp.XLabel=ReadString(fid);
                temp.YLabel=ReadString(fid);
                temp.ZLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.Data=ReadFloatArray(fid);
                temp.Data=reshape(temp.Data,[NY NX NZ]);
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end
        case 4 % PFTNV3
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTNV3');
                NX=ReadLong(fid); %#ok<NASGU>
                NY=ReadLong(fid); %#ok<NASGU>
                NZ=ReadLong(fid); %#ok<NASGU>
                ReadWord(fid,5); % skip ISPARE
                temp.X=ReadFloatArray(fid);
                temp.Y=ReadFloatArray(fid);
                temp.Z=ReadFloatArray(fid);
                temp.XLabel=ReadString(fid);
                temp.YLabel=ReadString(fid);
                temp.ZLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.VX=ReadFloatArray(fid);
                temp.VY=ReadFloatArray(fid);
                temp.VZ=ReadFloatArray(fid);
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end            
        case 5 % PFTVTX
            data=struct('Format','pff','PFFdataset','PFTVTX');
            data.VertexDim=ReadWord(fid);
            data.AttributeDim=ReadWord(fid);
            data.NumVertices=ReadLong(fid);
            ReadWord(fid,5); % skip ISPARE
            data.VertexLabel=cell(data.VertexDim,1);
            for m=1:data.VertexDim
                data.VertexLabel{m}=ReadString(fid);
            end
            data.AttributeLabel=cell(data.AttributeDim,1);
            for n=1:data.AttributeDim
                data.AttributeLabel{n}=ReadString(fid);
            end
            if (VDS==-3) && (data.VertexDim>0)
                data.VertexList=ReadFloatArray(fid);
                data.VertexList=reshape(data.VertexList,...
                    [data.VertexDim data.NumVertices]);
            elseif VDS==1
                data.VertexList=ReadFloatArray(fid);
            end
            data.AttributeList=ReadFloatArray(fid);
        case 6 % PFTIFL
            data=struct('Format','pff','PFFdataset','PFTIFL');
            data.FloatFlag=ReadWord(fid);
            data.FloatListLength=ReadLong(fid);
            data.IntegerArray=ReadIntegerArray(fid);
            data.FloatList=nan(data.FloatListLength,1);
            for n=1:data.FloatListLength
                data.FloatList(n)=ReadFloat(fid);
            end
            if data.FloatFlag~=0
                data.FloatArray=ReadFloatArray(fid);
            end
        case 7 % PFTNGD
            data=struct('Format','pff','PFFdataset','PFTNGD');
            M=ReadWord(fid);
            N=ReadWord(fid);
            if VDS==1
                data.NX=ReadLong(fid,M);
            else
                data.NX=ReadWord(fid,M);
            end
            ReadIntegerArray(fid); % spare entry
            data.ALABEL=cell(1,M);
            for m=1:M
                data.ALABEL{m}=ReadString(fid);
            end
            data.VLABEL=cell(1,N);
            for n=1:N
                data.VLABEL{n}=ReadString(fid);
            end
            data.X=cell(1,M);
            for m=1:M
                data.X{m}=ReadFloatArray(fid);
            end
            data.Data=cell(N,1);
            for n=1:N
                data.Data{n}=reshape(ReadFloatArray(fid),data.NX);
                data.Data{n}=transpose(data.Data{n});
            end
        case 8 % PFTNG3
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTNG3');
                NX=ReadLong(fid); %#ok<NASGU>
                NY=ReadLong(fid); %#ok<NASGU>
                NZ=ReadLong(fid); %#ok<NASGU>
                ReadIntegerArray(fid); % spare entry
                temp.X=ReadFloatArray(fid);
                temp.Y=ReadFloatArray(fid);
                temp.Z=ReadFloatArray(fid);
                temp.XLabel=ReadString(fid);
                temp.YLabel=ReadString(fid);
                temp.ZLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end
        case 9 % PFTNI3
            NBLKS=ReadWord(fid);
            data=cell(1,NBLKS);
            for block=1:NBLKS
                temp=struct('Format','pff','PFFdataset','PFTNI3');
                NX=ReadLong(fid); %#ok<NASGU>
                NY=ReadLong(fid); %#ok<NASGU>
                NZ=ReadLong(fid); %#ok<NASGU>
                ReadIntegerArray(fid); % spare entry
                temp.X=ReadFloatArray(fid);
                temp.Y=ReadFloatArray(fid);
                temp.Z=ReadFloatArray(fid);
                temp.XLabel=ReadString(fid);
                temp.YLabel=ReadString(fid);
                temp.ZLabel=ReadString(fid);
                temp.BLabel=ReadString(fid);
                temp.IArray=ReadIntegerArray(fid);
                temp.TypeLabel=TYPE;
                temp.Title=TITLE;
                data{block}=temp;
            end
            if numel(data)==1
                data=data{1};
            end
        otherwise
            error('ERROR: unrecognized dataset type detected');
    end
end

end

% this function is used for debugging purposes only
function ReadBuffer(fid,N) %#ok<DEFNU>

if nargin<2
    N=64;
end

pos=ftell(fid);
value=fread(fid,N,'uint8');
value=reshape(value,[1 numel(value)]);
fprintf('%s\n',value);
fprintf('%s\n',char(value));
fseek(fid,pos,'bof');

end