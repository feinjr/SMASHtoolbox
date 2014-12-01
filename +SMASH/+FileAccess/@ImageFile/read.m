% READ Read file associated with a ImageFile object
%
% Syntax:
%    >> output=read(object,[option]);
% The option input is used for formats files containing more than one
% image.  The output is a structure with the following fields.
%    -FileName
%    -FileType
%    -FileOption
%    -Grid1
%    -Grid2
%    -Data
%
% See also ImageFile, probe, select
%

function output=read(object,~)

% handle input
%if nargin<2
%    record=[];
%end

% error checking
assert(exist(object.FullName,'file')==2,...
    'ERROR: cannot read file because it does not exist');

% call the appropriate reader
output.FileName=object.FullName;
output.Format=object.Format;
map=jet(64);
switch object.Format
    case 'winspec'
        data=read_winspec(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    case 'optronis'
        data=read_optronis(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    case 'film'
        [data,grid1,grid2]=read_film(object.FullName);        
    case 'plate'
       [data,grid1,grid2]=read_plate(object.FullName);
    case 'sbfp'
        data=read_sbfp(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    case 'graphics'
        [data,map]=imread(object.FullName);        
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    otherwise       
       error('ERROR: invalid format');
end

output.Data=data;
output.Grid1=grid1;
output.Grid2=grid2;
output.ColorMap=map;

end

