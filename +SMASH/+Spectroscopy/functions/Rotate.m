%This function uses the image class to rotate the image by some given
%angle. The function takes the image data and angle as inputs.

function RotatedData=Rotate(image,angle)
   import SMASH.ImageAnalysis.Image
   object=Image(1:size(image,2),1:size(image,1),image);
   object=rotate(object,angle);
   RotatedData=object.Data;
   RotatedData=RotatedData(2:size(RotatedData,1)-1,2:size(RotatedData,2)-1);
end