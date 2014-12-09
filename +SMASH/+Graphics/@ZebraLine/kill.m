function object=kill(object)

delete(object.Group);
object.Status='dead';
object.Group=[];

end