% trackPower Track bounded region in the STFT power spectrum
function result=trackPower(object,boundary,method,threshold)

% manage input
if (nargin<3) || isempty(method)
    method='centroid';
end

if (nargin<4) || isempty(threshold)
    threshold=0;
end

N=numel(boundary);
result=cell(1,N);
for n=1:N
    result{n}=analyze(object,...
        @(x,y) singlePeak(x,y,method,threshold),boundary{n});
end

end