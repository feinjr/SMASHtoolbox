% export Export results to a text file
%
% This method exports velocity results to a text file
%    export(object,filename,
%

%
%
%
function export(object,filename,index,format)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(ischar(filename) && ~isempty(filename),'ERROR: invalid file name');

if (nargin < 3) || isempty(index)   
    index='all';
end
Nboundary=numel(object.Boundary);
valid=1:Nboundary;
if strcmpi(index,'all')
    index=valid;
elseif isnumeric(index)
    for m=1:Nboundary
        assert(any(index(M)==valid),'ERROR: invalid boundary index');
    end
end

if (nargin < 4) || isempty(format)
    format='%+#.5g %#.5g %#.5g\n';
end

% place data into file
fid=fopen(filename,'w');
CU=onCleanup(@() fclose(fid));
fprintf(fid,'PDV data exported %s\n',datestr(now));
fprintf(fid,'Column format: Time Velocity Uncertainty \n');

for m=1:numel(index)
    result=object.Velocity{index(m)};
    fprintf(fid,'\nResults for "%s"\n',result.Name);    
    data=[result.Grid result.Data];
    fprintf(fid,format,transpose(data));
end

end