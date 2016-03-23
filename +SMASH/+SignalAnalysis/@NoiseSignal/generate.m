% generate Generate noise 
%
% This method generates a noise measurement based on the current amplitude
% and transfer table.
%    object=generate(object);
% NOTE: object changes do NOT automatically generate a new noise
% measurement.  This method should be called after amplitude/transfer
% changes are complete.
% 
% See also NoiseSignal, defineTransfer
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=generate(object)

% temporarily reset random seed
if ~isempty(object.SeedValue)
    previous=rng();
    rng(object.SeedValue);
end

% generate random noise
noise=randn(object.Npoints,1);

% apply transfer function
transform=fft(noise,object.Npoints2);
transfer=interp1(...
    object.TransferTable(:,1),object.TransferTable(:,2),...
    abs(object.ReciprocalGrid));
transform=transform.*transfer;
noise=ifft(transform);
noise=real(noise(1:object.Npoints));

%
Data=noise*(object.Amplitude/std(noise));
Grid=object.Measurement.Grid;
object.Measurement=reset(object.Measurement,Grid,Data);

% restore previous random state
if ~isempty(object.SeedValue)
    rng(previous);
end

end