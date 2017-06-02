function obj=RotateImage(obj,source,output)
%The RotateImage takes image data as an input and rotates the
%image according to two points selected by the user. The image
%is rotated so that the selected points are horizontal.Once the
%image has been satisfactorily rotated the user can exit the
%GUI window, and the rotated image and angle will be returned.
%example: RotatedImage=obj.RotateImage(image)
%
%'All' is an optinal input, which rotates all images in the
%class (Data, Wavelength, and Time) to the same angle.
%example: obj.RotateImage(image,'All')


% manage input
assert(ischar(source),'ERROR: invalid source')
source=lower(source);
switch source
    case 'wavelength'
        ref=obj.WavelengthImage;
    case 'time'
        ref=obj.TimeImage;
    otherwise
        error('ERROR: invalid rotation source');
end

assert(ischar(output),'ERROR: invalid output');
output=lower(output);

[~,angle]=RotateSpectraGUI(ref);
%RotatedData(isnan(RotatedData))=0;

switch output
    case 'all'
        obj.WavelengthImage=Rotate(obj.WavelengthImage,angle);
        obj.TimeImage=Rotate(obj.TimeImage,angle);
        obj.DataImage=Rotate(obj.DataImage,angle);        
        obj.DataImage(isnan(obj.DataImage))=0;
        obj.TimeImage(isnan(obj.TimeImage))=0;
        obj.WavelengthImage(isnan(obj.WavelengthImage))=0;
    case 'wavelength'
        
    case 'time'
        
    case 'data'
        
    otherwise
            
end

end