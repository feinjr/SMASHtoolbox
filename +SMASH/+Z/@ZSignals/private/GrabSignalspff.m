function object = GrabSignalspff(fileName,sName)
a = SMASH.FileAccess.probeFile(fileName,[]);

% find indeces of signals corresponding to sName
% assumes signals are consecutive
k = 0;
for i = 1:size(a,2)
    out = regexp(a(i).Title,sName,'match');
    if ~isempty(out);
        k = k+1;
        record(k) = i;
    end
end
N = k;
n = 0;
sig = cell(N,1);
legend = cell(N,1);

numsamples = zeros(N,1);
for i = 1:length(record)
    r = record(i);
    n = n+1;
    d = SMASH.FileAccess.readFile(fileName,[],r);
    sig{n} = SMASH.SignalAnalysis.Signal(d.X, d.Data);
    legend{n} = a(r).Title;
    if n == k
        for k = 1:N; numsamples(k) = length(sig{k}.Grid); end
        [N,I] = max(numsamples);
        x = sig{I}.Grid;
        Data = zeros(N,n);
        for j = 1:n; sig{j} = regrid(sig{j},x); Data(:,j) = sig{j}.Data; end
        object = SMASH.SignalAnalysis.SignalGroup(sig{1}.Grid,Data);
        object.Legend = legend;
    end
end

