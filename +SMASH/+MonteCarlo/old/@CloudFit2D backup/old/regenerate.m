% regenerate Resample data clouds
%
% This method resamples all Cloud objects stored in a CloudFitXY object.
%    >> object=regenerate(object)
%
% See also CloudFitXY
%

%
% created October 17, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=regenerate(object)

for k=1:object.NumberClouds
    temp=object.Clouds{k};
    temp.NumberPoints=object.CloudSize;
    temp=generate(temp);
    object.Clouds{k}=temp;
end

end