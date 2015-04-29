function object=read(object,filename)

% manage input
if (nargin<2) || isempty(filename)
   [filename,pathname]=uigetfile({'*.*','All files'},...
       'Select LUNA file');
   if isnumeric(filename)
       error('ERROR: source file not read');
   end
   filename=fullfile(pathname,filename);
end

% read file based on extension
assert(exist(filename,'file')==2,'ERROR: source file does not exist');

[~,shortname,extension]=fileparts(filename);
switch lower(extension)
    case '.obr'
        [time,signal,header]=read_OBR(filename);
    otherwise
        [time,signal,header]=read_text(filename);
end
object.SourceFile=[shortname extension];
object.FileHeader=header;
object.Time=single(time(:));
object.LinearAmplitude=single(signal(:));
object.IsModified=false;

end
