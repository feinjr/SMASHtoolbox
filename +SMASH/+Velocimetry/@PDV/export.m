% export Export results to a text file
%
% This method exports velocity results to a text file.  All velocities are
% exported by default; specific results can be requested by index.
%    export(object,filename)
%    export(object,filename,index);
% The input "index" can be an array of integers or the string 'all'.
%
% Five significant digits per column are written by default.  Custom
% formats may also be specified
%    export(object,filename,'%#.10g %#.10g'); % two columns with ten signficant digits
% NOTE: the number of columns 
%

%
%
%
function export(object,filename,index,format)

assert(object.Analyzed,'ERROR: analysis has not been performed yet');
velocity=object.Velocity;

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(ischar(filename) && ~isempty(filename),'ERROR: invalid file name');

if (nargin < 3) || isempty(index)   
    index='all';
end
Nboundary=numel(velocity);
valid=1:Nboundary;
if strcmpi(index,'all')
    index=valid;
elseif isnumeric(index)
    for m=1:Nboundary
        assert(any(index(M)==valid),'ERROR: invalid boundary index');
    end
end

if (nargin < 4) 
    format='';    
end

% check output format
if object.NoiseDefined
    if isempty(format)
        format='%+#.5g %#.5g %#.5g\n';
    else
        assert(sum(format=='%')==3,'ERROR: invalid format for 3 data columns');
    end
else
    if isempty(format)
        format='%+#.5g %#.5g\n';
    else
        assert(sum(format=='%')==2,'ERROR: invalid format for 2 columns');
    end
end
if isempty(strfind(format,'\n'))
    format=[format '\n'];
end


% place data into file
fid=fopen(filename,'w');
CU=onCleanup(@() fclose(fid));
fprintf(fid,'PDV data exported %s\n',datestr(now));
fprintf(fid,'Column format: Time Velocity Uncertainty \n');

for m=1:numel(index)
    if object.NoiseDefined
        uncertainty=object.Uncertainty{index(m)};
        data=[velocity{m}.Grid(:) velocity{m}.Data(:) uncertainty{m}.Data(:)];
    else
        data=[velocity{m}.Grid(:) velocity{m}.Data(:)];
    end
    fprintf(fid,'\nResults for "%s"\n',velocity{m}.Name);    
    fprintf(fid,format,transpose(data));
end

end