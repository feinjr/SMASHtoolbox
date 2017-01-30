function [success,filename]=loadImage(name,himage)

success=false;

label=sprintf('Select %s image file',name);
[filename,pathname]=uigetfile('*.*',label);
if isnumeric(filename)
    return
end

filename=fullfile(pathname,filename);
object=SMASH.ImageAnalysis.Image(filename);
set(himage,'XData',object.Grid1,'YData',object.Grid2,'CData',object.Data,...
    'Visible','on');

setappdata(himage,'ReferenceIamge',object);
success=true;

end