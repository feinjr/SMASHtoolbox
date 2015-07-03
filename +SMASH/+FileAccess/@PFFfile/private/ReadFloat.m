function result=ReadFloat(fid)

word=fread(fid,3,'int16');
%word=fread(fid,3,'uint16');
two15=pow2(15);
rtwo15=1/two15;

result=(1-2*mod(word(3),2))*...
    ((word(2)*rtwo15+word(1))*rtwo15+1)*...
    2^(word(3)/2-8193);

end