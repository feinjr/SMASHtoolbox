function clearScreen(object)

communicate(object);
fwrite(object.VISA,'*CLS');
% this does not work as I intended!

end