function success = export(object,varargin)
    
% EXPORT Export the data contained in the sesame object to a text or *.sda 
% file. At a minimum, the method requries the object and a filename. If the 
% object is a sesame table, a 201 and 301 table in the Kerley format is 
% saved. In this case, a minimum of a material number is also required:
%
%   >> export(object,filename,neos);
%
% The 201 table can be specified with additional inputs
%
%   >> export(object,filename,neos, Z, W, rho0, K0, T0);
%
% If the object is a curve through phase space (isentrope, isotherm, etc.),
% the file is saved in column format with the appropriate thermodyanmic
% variables. 
%   >> export(object,filename);
%
% The output is a logical flag indicating if the write was succesful
% (true).
%
% created April 28, 2014 by Justin Brown (Sandia National Labs)

numarg = nargin-1;
%Error checking
if (numarg<1) 
    error('Require at least object and filename');
end

filename = varargin{1};

%Initial input variables
if (numarg>1)
  
    neos = varargin{2};
    
    %Table 201 parameters
    z=1;
    w=1;
    d0 = min(object.Density);
    b0 = 1;
    T0 = 298; 
%     z=79;       %Gold
%     w = 1.9697e2;
%     d0 = 19.287804;
%     b0 = 1.66952993E+02;
%     T0 = 298;
end
if (numarg>2)
    z = varargin{3};
end
if (numarg>3)
   w = varargin{4};
end
if (numarg>4)
   d0 = varargin{5};
end
if (numarg>5)
   b0 = varargin{6};
end
if (numarg>6)
   T0 = varargin{7};
end

switch lower(object.SourceFormat)
    %Sesame table output
    case 'sesame'
        assert(numarg > 1,'Sesame table detected, must specify material number');
        if exist(filename,'file')
            message{1}='Target file already exists.';
            message{2}='Should it be overwritten?';
            choice=questdlg(message,'Overwrite file','Yes','No','No');
            if strcmp(choice,'Yes')
                delete(filename);
            else
                return
            end
        end

        fid=fopen(filename,'w');     


        %Table 301 parameters
        nD = length(unique(object.Density));
        nT = length(unique(object.Temperature));
        nwds = nD+nT+2+3*(nD*nT);
        data = vertcat(nD,nT,unique(object.Density),unique(object.Temperature),object.Pressure,object.Energy,object.Entropy);

        % write the file
        try
            fprintf(fid,'INDEX        MATID = %i    NWDS = 9 \n',neos);
            fprintf(fid,'  %e  %e  %e  %e  %e\n',neos,0,0,1,2);
            fprintf(fid,' %e %e %e %e\n',201,301,5,nwds);
            fprintf(fid,'RECORD       TYPE = 201    NWDS = 5\n');
            fprintf(fid,' %e %e %e %e %e\n',z,w,d0,b0,T0);
            fprintf(fid,'RECORD       TYPE = 301    NWDS = %i\n',nwds);
            fprintf(fid,' %e %e %e %e %e\n',data);
            success=true;
        catch
            success=false;
        end

        finish=onCleanup(@() fclose(fid));
    
    %Curve output    
    otherwise        
        data =[];
        header = sprintf('Density\tTemperature\tPressure\tEnergy\tEntropy');
            
        if strcmpi(object.SourceFormat,'isentrope')
            header = sprintf('%s\tParticleVelocity\tLagWavespeed',header);
            [data(:,1),data(:,2),data(:,3),data(:,4), ...
            data(:,5),data(:,6),data(:,7)]= limit(object);
            
        elseif strcmpi(object.SourceFormat,'hugoniot')
            header = sprintf('%s\tParticleVelocity\tShockVel',header);
            [data(:,1),data(:,2),data(:,3),data(:,4), ...
            data(:,5),data(:,6),data(:,7)]= limit(object);
        else
            
        [data(:,1),data(:,2),data(:,3),data(:,4), ...
        data(:,5)]= limit(object);
        end
        
        format=repmat('%#+e\t',[1 min(size(data))]);
        format=[format '\n'];
        
        % place data into file
        [~,~,ext]=fileparts(filename);
        if strcmpi(ext,'.sda')

            if isempty(varargin{2})
               label = object.Name;
            else
               label = varargin{2};
            end
            archive=SMASH.FileAccess.SDAfile(filename);
            archive.Precision=object.Precision;
            archive.Deflate=9;
            %Save *.sda as a structure
            datastruct = struct;
            datastruct.Density = object.Density;
            datastruct.Temperature = object.Temperature;
            datastruct.Pressure = object.Pressure;
            datastruct.Energy = object.Energy;
            datastruct.Entropy = object.Entropy;
            
            if strcmpi(object.SourceFormat,'isentrope')
                datastruct.ParticleVelocity = data(:,6);
                datastruct.EulWavespeed = data(:,7);
            end
            
            if strcmpi(object.SourceFormat,'hugoniot')
                datastruct.ParticleVelocity = data(:,6);
                datastruct.ShockVelocity = data(:,7);
            end
                      
            insert(archive,'structure',label,datastruct);
        else
            SMASH.FileAccess.writeFile(filename,data,format,header);
        end
end

end


