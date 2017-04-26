function unlock(object)

communicate(object);
fwrite(object.VISA,'SYSTEM:LOCK OFF');
fwrite(object.VISA,'SYSTEM:GUI ON');
message(object,'');

end