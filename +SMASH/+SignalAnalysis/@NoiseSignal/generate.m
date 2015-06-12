function object=generate(object,varargin)

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

% restore previous ra
if ~isempty(object.SeedValue)
    rng(previous);
end

end