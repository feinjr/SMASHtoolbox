function object=RestoreFile(object,filename,label)

% access archive
archive=SMASH.FileAccess.SDAfile(filename);

if (nargin<3) || isempty(label)
    contents=probe(archive);
    label=contents{1};    
else
    match=probe(archive,label);
    assert(~isempty(match),'ERROR: label not found in archive');
end

% read Signal entry
target=['/' label];
try
    parent=h5readatt(filename,target,'Class');
catch
    error('ERROR: requested record is not a Signal object');
end
assert(strcmp(parent,'SMASH.SignalAnalysis.Signal'),...
    'ERROR: requested record is not a Signal object');
data=extract(archive,label);

% transfer structure into array
[~,name,ext]=fileparts(filename);
data.Source=[name ext];
data.SourceRecord=label;
object=revealProperty(object,'SourceFormat','SourceRecord');

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end