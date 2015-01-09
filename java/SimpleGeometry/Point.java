package SimpleGeometry;
/*
This class represents points in a two-dimensional coordinate system.

A=Point(X,Y);

Properties: X, Y, L2

Methods:
	P=vectorComponents(A,B); // vector component between two points, returned as a new Point object

created January 8, 2015 by Daniel Dolan (Sandia National Laboratories)
*/

public class Point
{
	public double X=0;
	public double Y=0;
	public double L2=0; // zero distance between a point and itself

public Point(double x, double y)
{
	X=x;
	Y=y;
}

public static Point vectorComponents(Point A, Point B)
{
	Point result=new Point(0,0);
	result.X=B.X-A.X;
	result.Y=B.Y-A.Y;
	result.L2=result.X*result.X+result.Y*result.Y;
	return result;
}
	
}