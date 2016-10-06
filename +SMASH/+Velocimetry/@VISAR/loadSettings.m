% LOADSETTINGS - Load the Settings for a VISAR object
%
% This method loads the settings for the current VISAR object from a file
%     >> object=loadSettings(object,filename)
%     >> object=loadSettings(object)
%
% If a filename is specified, it must be in the current directory.  If no 
% filename is specified the user is prompted to locate the file.  
%
% created March 21, 2016 by Paul Specht (Sandia National Laboratories)

function object=loadSettings(object,filename)

%manage input
if nargin == 1
    [filename,pathname]=uigetfile({'*.*','All files'},'Select file');
elseif nargin == 2
    d=dir(filename);
    if isempty(d)
        error('ERROR:  No Such File in Current Directory. ');
    else
        pathname=[cd,'/'];
    end
elseif nargin > 2
    error('ERROR:  Invalid loadSettings Input. ');
end

%open settings file
f=fopen([pathname,filename]);
tline=fgetl(f);
L={'Label','Notes','Timeshifts','VerticalOffsets','VerticalScales',...
    'VPF','InitialVelocity','EllipseParameters','ReferenceRegion',...
    'ExperimentalRegion','Jumps'};
while ischar(tline)
    counter=1;
    finding=1;
    while finding == 1
        if isempty(strfind(tline,L{counter})) == 0
            a=strfind(tline,'{');
            b=strfind(tline,'}');
            if isempty(a) || isempty(b) 
                error(['ERROR:  Inproper ',L{counter},' Description. ']);
            else
                op=tline(a(1)+1:b(1)-1);
                if counter == 1
                    object.Label=op;
                elseif counter == 2
                    object.Notes=op;
                elseif counter == 3
                    object.TimeShifts=str2num(op);
                elseif counter == 4
                    object.VerticalOffsets=str2num(op);
                elseif counter == 5
                    object.VerticalScales=str2num(op);
                elseif counter == 6
                    object.VPF=str2num(op);
                elseif counter == 7
                    object.InitialVelocity=str2num(op);
                elseif counter == 8
                    object.EllipseParameters=str2num(op);
                elseif counter == 9
                    object.ReferenceRegion=str2num(op);
                elseif counter == 10
                    object.ExperimentalRegion=str2num(op);
                elseif counter == 11
                    J=zeros(length(a),3);
                    for k=1:length(a)
                        js=tline(a(k)+1:b(k)-1);
                        J(k,:)=str2num(js);
                    end
                    object.Jumps=J;
                end
                finding=0;
                tline=fgetl(f);
            end
        elseif counter == 11
            finding=0;
            tline=fgetl(f);
        else 
            counter=counter+1;
        end
    end
end
   