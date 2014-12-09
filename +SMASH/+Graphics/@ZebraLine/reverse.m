function object=reverse(object)

temp=object.ForegroundColor;
object.ForegroundColor=object.BackgroundColor;
object.BackgroundColor=temp;

end