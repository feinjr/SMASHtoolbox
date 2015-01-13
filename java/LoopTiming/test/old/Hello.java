/* A dynamic program to print "Hello, world!" */ 
public class Hello {

public Hello(String name) // constructor method
{ 
	System.out.println("Hello, " + name + "!");
	System.out.println("This is nice");
}
	
public static void main(String[] arg) 
{
	new Hello("world"); // create a new Hello object
}

}