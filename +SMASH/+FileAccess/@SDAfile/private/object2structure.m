function data=object2structure(object)

warning off MATLAB:structOnObject
data=struct(object);
warning on MATLAB:structOnObject

end