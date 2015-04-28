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
assert(exist(filename,'file'),'ERROR: source file does not exist');

[~,~,extension]=fileparts(filename);
switch lower(extension)
    case '.obr'
        data=read_OBR(filename);
    otherwise
        data=read_text(filename);
end

% transfer data into object

end
