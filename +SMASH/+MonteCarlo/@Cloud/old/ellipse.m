function varargout=ellipse(varargin)

message={};
message{end+1}={'ERROR: this method has been removed'};
message{end+1}={'       Use the density method instead'};
error('%s\n',message{:});

end