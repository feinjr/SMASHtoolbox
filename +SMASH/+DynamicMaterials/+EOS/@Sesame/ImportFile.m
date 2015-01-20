function object=ImportFile(object,filename,material)
    
% This program reads a sesame table.  For example:
%
%   >> object=sesame(object,filename,material);
%
% extracts the SESAME 301 table for the specified material from the
% specified file (binary or ASCII format).  Two storage conventions ('LANL'
% and 'SNL') are supported, with 'LANL' as the default.  The reference
% density for the material is extracted from the SESAME 201 table, which
% should be located in the same file as the 301 table. 
%

% created April, 17 2014 by Justin Brown (Sandia National Labs)

    % extract reference state
    %data=sesame_read(filename,material,201);
    %T0=298.15; % K
    %rho0=data(3);
    %rho0=rho0*1e3; % convert to kg/m^3

    % extract EOS from table 301
    [data,convention]=sesame_read(filename,material,301);
    NR=data(1);
    NT=data(2);
    data=data(3:end);

    density=data(1:NR); % Mg/m^3
    data=data((NR+1):end);
    %density=density*1e3; % convert to kg/m^3
    density=density(:);
    density=repmat(density,[1 NT]);
    density=density(:);

    temperature=data(1:NT); % K
    data=data((NT+1):end);
    temperature=transpose(temperature(:));
    temperature=repmat(temperature,[NR 1]);
    temperature=temperature(:);

    stop=NR*NT;
    index=1:stop;
    potential=nan(size(density));

    try
        pressure=data(index); % GPa
        %pressure=pressure*1e9; % convert to Pa
        index=index+stop;
        energy=data(index); % MJ/kg
        %energy=energy*1e6; % convert to J/kg
        index=index+stop;
        potential=data(index); % MJ/kg or MJ/kg*K
        %potential=potential*1e6; % convert to J/kg or J/(kg*K)
    catch
        fprintf('Warning: incomplete EOS (SESAME 301) table \n');    
    end
    switch lower(convention)
        case 'lanl' % table contains energy/helmholtz free energy
            helmholtz=potential;
            entropy=zeros(size(helmholtz));
            keep=(temperature>1e-6);
            entropy(keep)=(energy(keep)-helmholtz(keep))./temperature(keep);
            T1=min(temperature(keep));
            f1=helmholtz(temperature==T1);
            T=unique(temperature(~keep));
            for k=1:numel(T)
                fix=(temperature==T(k));
                f=helmholtz(fix);
                entropy(fix)=-(f-f1)./(T(k)-T1);
            end
        case {'snl','kerley'} % table contains energy/entropy
            entropy=potential;
            %helmholtz=energy-temperature.*entropy;
        otherwise
            error('ERROR: %s is not a valid convention');
    end
    
    %Extract any table comments
    comments={};
    try
        for table=101:199
            comments{end+1}=sesame_read(filename,material,table);
        end
    catch
        % do nothing
    end

    %Ensure entropy > 0
    %if min(entropy) < 0;
    %    entropy = entropy - min(entropy); 
    %end
    
    %Define EOS table points
    object.Density=density;
    object.Temperature=temperature;
    object.Pressure=pressure;
    object.Energy=energy;
    object.Entropy=entropy;
    if ~isempty(comments)
        object.Comments = comments;
    end

end



% created 5/7/2010 by Daniel Dolan (Sandia National Labs)
%% File reader
function [data,style]=sesame_read(filename,material,table)

if nargin<3
    error('ERROR: file name, material number, and table number are required');
end
[fileformat,style]=sesame_info(filename);

if strcmp(fileformat,'ascii')
    if strcmp(style,'lanl')
        data=lanl_ascii(filename,material,table);
    else
        data=kerley_ascii(filename,material,table);
    end     
else
    if strcmp(style,'lanl')
        data=lanl_binary(filename,material,table);
    else
        data=kerley_binary(filename,material,table);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%
% ASCII file readers %
%%%%%%%%%%%%%%%%%%%%%%
function data=lanl_ascii(filename,material,table)

% locate material
fid=fopen(filename,'rt');
done=false;
while ~done 
    if feof(fid)
        error('ERROR: material %d table %d not found',material);
    end
    temp=strtrim(fgetl(fid));       
    [value,count]=sscanf(temp,'%d',3);
    if (count<3) || (material ~= value(2)) || (table ~= value(3))        
        continue             
    end
    done=true;
    %fprintf('Found material %d table %d...',material,table);
end    

% read table data
start=ftell(fid);
%fprintf('reading...');
if table<200
    done=false;
    data={};
    while ~done && ~feof(fid)
        temp=strtrim(fgetl(fid));
        [value,count]=sscanf(temp,'%d',3);
        if (count==3) && (temp(1)==temp(end)) && any(value(1)==[0 1]) % next material/table entry
            done=true;
            continue
        elseif (count==2)&& all(value==2) % tabular file termination
            done=true;
            continue
        else
            data{end+1}=temp;
        end
        data=sprintf('%s\n',data{:});
    end
else
    temp=fgets(fid);
    fseek(fid,start,'bof');
    skip=6; % five character count + end of line
    width=numel(temp)-skip;
    format=sprintf('%%%dc%%*%dc',width,skip);
    if table==201
        numline=1;
    elseif (table>=301) && (table<=307)        
        temp=fscanf(fid,'%g',2);
        fseek(fid,start,'bof');
        NR=temp(1);
        NT=temp(2);
        numline=ceil((2+NR+NT+3*NR*NT)/5);
    else
        error('ERROR: table %d not supported',table);
    end
end
data=fscanf(fid,format,numline);
data=sscanf(data,'%g');
%fprintf('done\n');

end

function data=kerley_ascii(filename,material,table)

% locate material
fid=fopen(filename,'rt');
done=false;
while ~done 
    if feof(fid)
        error('ERROR: material %d not found',material);
    end
    temp=strtrim(fgetl(fid));
    value=sscanf(temp,'%s',1);
    if strcmpi(value,'index')
        index=find(temp=='=',1,'first');
        value=sscanf(temp(index+1:end),'%d',1);
        if material==value
            %fprintf('Found material %d...',material);
            done=true;            
        end
    end   
end

% locate table
done=false;
while ~done
    if feof(fid)
        error('ERROR: material %d table %d not found',material,table);
    end
    temp=strtrim(fgetl(fid));
    value=sscanf(temp,'%s',1);
    if strcmpi(value,'record')
        index=find(temp=='=',1,'first');
        value=sscanf(temp(index+1:end),'%d',1);
        if table==value
            %fprintf('table %d...',table);
            done=true;
            %fprintf('reading...');
            index=find(temp=='=',1,'last');
            nwds=sscanf(temp(index+1:end),'%d',1);
            data=fscanf(fid,'%g',nwds);
        end
    end   
end
%fprintf('done\n');

fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%
% binary file readers %
%%%%%%%%%%%%%%%%%%%%%%%
function [data,info]=lanl_binary(filename,material,table)

% open file 
fid=fopen(filename,'r','b');
precision='double';
wordsize=8; % 64-bit word

% read main information
N=fread(fid,1,precision);
date0=fread(fid,1,precision);
vers0=fread(fid,1,precision);

matid=fread(fid,N,precision);
nwds=fread(fid,N,precision);
iadr=fread(fid,N,precision);

% locate the specified material
k=find(matid==material);
if isempty(k)
    error('ERROR: material %d not found',material);
end
offset=iadr(k)*wordsize;
fseek(fid,offset,'bof');

% read the index record
info.matid=fread(fid,1,precision);
info.date1=fread(fid,1,precision);
info.date2=fread(fid,1,precision);
info.vers=fread(fid,1,precision);
ntable=fread(fid,1,precision);
tblid=fread(fid,ntable,precision);
nwds=fread(fid,ntable,precision);
iadr=fread(fid,ntable,precision);

% locate the specified table
k=find(tblid==table);
if isempty(k)
    error('Table %d for material %d not found',table,material);
end
offset=offset+iadr(k)*wordsize;
nwds=nwds(k);
fseek(fid,offset,'bof');

% read table data
if table<200 
    data=fread(fid,nwds*wordsize,'char');
    data=char(data');
else
    data=fread(fid,nwds,precision);
end

% close file
fclose(fid);

end

function data=kerley_binary(filename,material,table)
data=[];
% open file 
fid=fopen(filename,'r','ieee-le');
precision='single';
wordsize=4; % 32-bit word

% read directory records
numbyteA=fread(fid,1,'uint32');
N=fread(fid,1,precision);
date0=fread(fid,1,precision);
vers0=fread(fid,1,precision);
numbyteB=fread(fid,1,'uint32');

numbyteA=fread(fid,1,'uint32');
matid=fread(fid,N,precision);
nwds=fread(fid,N,precision);
numbyteB=fread(fid,1,'uint32');

k=find(matid==material);
if isempty(k)
    error('ERROR: material %d not found',material);
end

% locate material
m=0;
while ~feof(fid)
    try
        numbyte=fread(fid,1,'uint32'); % header
        junk=fread(fid,numbyte/wordsize,precision); % material separator
        numbyte=fread(fid,1,'uint32'); % trailer
        numbyte=fread(fid,1,'uint32'); % header
        record1=fread(fid,numbyte/wordsize,precision); % material heading
        matid=record1(1);
        numtable=record1(5);
        index=5+(1:numtable);
        tblid=record1(index);
        numbyte=fread(fid,1,'uint32'); % header
        for n=1:numtable
            numbyte=fread(fid,1,'uint32'); % header
            temp=fread(fid,numbyte/wordsize,precision);
            if (matid==material) && (tblid(n)==table) % successful exist
                data=temp;
                fclose(fid);
                return;
            end
            numbyte=fread(fid,1,'uint32'); % trailer
        end
    catch
        break
    end
end

% unsuccessful exit
fclose(fid);
error('Table %d for material %d not found',table,material);

end

%%
% sesame_info : information about a SESAME tabular file
%
% This function determines the format, style, and material contents of a
% SESAME tabular file.
%
% Usage:
%   >> [filetype,style]=sesame_info(filename);
%   >> [filetype,style,material]=sesame_info(filename);
% The second form may be slow for ASCII files.

% created 5/7/2010 by Daniel Dolan (Sandia National Labs)
function [filetype,style,material]=sesame_info(filename)

% handle input and specify default behavior
if (nargin<1) || isempty(filename)
    [filename,pathname]=uigetfile('Select SESAME table file');
    if isnumeric(filename)
        return
    end
    filename=fullfile(pathname,filename);
end

% determine file type
try
    fid=fopen(filename,'rt');
    excerpt=fread(fid,1024,'char');
catch
    error('ERROR: unable to open file: \n %s',filename);
end
fclose(fid);

index=(excerpt==9);
excerpt(index)=[]; % remove tabs
index=(excerpt==10) | (excerpt==13);
excerpt(index)=[]; % remove new lines and carriage returns
index=(excerpt>=32) & (excerpt<=126);
excerpt(index)=[]; % remove standard keyboard characters
if isempty(excerpt)
    filetype='ascii';
else
    filetype='binary';
end

% determine file format
if nargout>=2
    if strcmp(filetype,'ascii')
        fid=fopen(filename,'rt');
        temp=fgetl(fid);
        a=sscanf(temp,'%s',1);
        fclose(fid);
        if strcmpi(a,'index');
            style='kerley';
        else
            style='lanl';
        end
    else
        style='';
        % check for Kerley style
        fid=fopen(filename,'r','l');
        numbyteA=fread(fid,1,'uint32');
        fseek(fid,numbyteA,'cof');
        numbyteB=fread(fid,1,'uint32');
        fclose(fid);
        if numbyteA==numbyteB
            style='kerley';
        else % check for LANL style
            fid=fopen(filename,'r','b');
            N=fread(fid,1,'double');
            fclose(fid);
            if N==floor(N)
                style='lanl';
            end            
        end
        if isempty(style)
            error('ERROR: unable to determine table style');
        end                
    end
end

% determine materials defined in file
if nargout>=3
    if strcmp(filetype,'ascii')
        fid=fopen(filename,'rt');
        material=[];
        while ~feof(fid)
            temp=strtrim(fgetl(fid));
            if numel(temp)<2
                continue
            end
            if strcmp(style,'lanl')
                bounds=[temp(1) temp(end)];
                if all(bounds=='0')
                    [value,count]=sscanf(temp,'%d',3);
                    if count==3
                        material(end+1)=value(2);
                    end
                end
            else
                value=sscanf(temp,'%s',1);
                if strcmpi(value,'index')
                    index=find(temp=='=',1,'first');
                    material(end+1)=sscanf(temp(index+1:end),'%d',1);
                end
            end
        end
        fclose(fid);
    else
        if strcmp(style,'lanl')
            fid=fopen(filename,'r','b');
            precision='double';
            % record 1
            N=fread(fid,1,precision);
            date0=fread(fid,1,precision);
            vers0=fread(fid,1,precision);
            % record 2
            material=fread(fid,N,precision);
        else            
            fid=fopen(filename,'r','l');
            precision='single';
            % record 1
            numbyteA=fread(fid,1,'uint32');
            N=fread(fid,1,precision);
            date0=fread(fid,1,precision);
            vers0=fread(fid,1,precision);
            numbyteB=fread(fid,1,'uint32');
            % record 2
            numbyteA=fread(fid,1,'uint32');
            material=fread(fid,N,precision);
            %nwds=fread(fid,N,precision);
            %iadr=fread(fid,N,precision);
            %numbyteB=fread(fid,1,'uint32');
            fclose(fid);
        end
    end
end

end







