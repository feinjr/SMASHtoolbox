package SimpleGeometry;

public class Segment
{
	public Point A = new Point(0,0);
	public Point B = new Point(0,0);
	
public Segment(Point a, Point b)
{
	A=a;
	B=b;
}

public Point lookup(double gamma)
{
	Point result = new Point(0,0);
	if (gamma<0) {gamma=0;}
	else if (gamma>1) {gamma=1;}
	result=vectorComponents(A,B);
	result.X=A.X+gamma*result.X;
	result.B=A.Y+gamma.result.Y;
}

public Point shortestPath(Point P)
{
	Point result = new Point(0,0);
	return Result;
}

public Point shortestConstrainedPath1(Point P, Point u, Point v)
{
	Point result = new Point(0,0);
	return Result;
}

}