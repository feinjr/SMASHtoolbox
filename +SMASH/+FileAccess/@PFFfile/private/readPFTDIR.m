function data=readPFTDIR(fid)

data=struct('Format','pff','PFFdataset','PFTDIR');
data.TRAW=readWord(fid);
data.Length=ReadLong(fid);
data.Location=readLong(fid);

end